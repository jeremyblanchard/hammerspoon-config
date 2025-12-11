-- Granola to Obsidian Automation Script
-- Place this in ~/.hammerspoon/init.lua or require it from there
--
-- SETUP:
-- 1. Copy this to ~/.hammerspoon/init.lua (or require it)
-- 2. Reload Hammerspoon config
-- 3. In Granola: Copy meeting note text
-- 4. Press Cmd+Shift+G to process and save
--
-- WORKFLOW:
-- Granola "Copy text" → Clipboard → Cmd+Shift+G → Saved to Obsidian Inbox

local obsidianPath = os.getenv("HOME") .. "/Documents/Obsidian/Inbox/"

-- Function to get current date in YYYY-MM-DD format
local function getCurrentDate()
    return os.date("%Y-%m-%d")
end

-- Function to get current timestamp for filename
local function getTimestamp()
    return os.date("%Y-%m-%d-%H%M")
end

-- Function to sanitize filename
local function sanitizeFilename(text)
    -- Take first line or first 50 chars as title
    local title = text:match("^([^\n]+)") or text:sub(1, 50)
    -- Remove special characters
    title = title:gsub("[^%w%s-]", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return title
end

-- Function to create frontmatter
local function createFrontmatter(title)
    local frontmatter = string.format([[---
date: %s
type: meeting
source: granola
tags:
  - meeting
  - granola
  - needs-processing
related_jira:
related_projects:
---

]], getCurrentDate())
    return frontmatter
end

-- Function to process and save Granola note
local function processGranolaNoteBasic()
    -- Get clipboard content
    local clipboardText = hs.pasteboard.getContents()

    if not clipboardText or clipboardText == "" then
        hs.alert.show("❌ Clipboard is empty")
        return
    end

    -- Create title from content
    local title = sanitizeFilename(clipboardText)
    local timestamp = getTimestamp()
    local filename = string.format("%s-granola-%s.md", timestamp, title)
    local filepath = obsidianPath .. filename

    -- Create content with frontmatter
    local frontmatter = createFrontmatter(title)
    local content = frontmatter .. "# " .. title .. "\n\n" .. clipboardText

    -- Write to file
    local file = io.open(filepath, "w")
    if file then
        file:write(content)
        file:close()
        hs.alert.show("✅ Saved to Obsidian Inbox")

        -- Optional: Open in Obsidian
        -- hs.execute(string.format('open "obsidian://open?path=%s"', filepath))
    else
        hs.alert.show("❌ Error saving file")
    end
end

-- Function to process with Claude synthesis (requires Claude API key)
local function processGranolaNoteWithClaude()
    local clipboardText = hs.pasteboard.getContents()

    if not clipboardText or clipboardText == "" then
        hs.alert.show("❌ Clipboard is empty")
        return
    end

    hs.alert.show("🤖 Processing with Claude...")

    -- Get API key from environment or keychain
    local apiKey = os.getenv("ANTHROPIC_API_KEY")

    if not apiKey then
        hs.alert.show("❌ ANTHROPIC_API_KEY not set")
        -- Fall back to basic processing
        processGranolaNoteBasic()
        return
    end

    -- Create Claude API request
    local prompt = string.format([[Analyze this Granola meeting transcript and create a structured summary:

1. Extract the meeting title/topic
2. Summarize key discussion points (3-5 bullets)
3. List all action items with owners if mentioned
4. List key decisions made
5. Extract any mentioned Jira tickets, PR numbers, or project names

Format as markdown with clear sections. Be concise.

Transcript:
%s]], clipboardText)

    local curlCommand = string.format([[
curl -s https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: %s" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 2048,
    "messages": [{"role": "user", "content": %s}]
  }'
]], apiKey, hs.json.encode(prompt))

    -- Execute async
    hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            -- Parse response
            local success, response = pcall(hs.json.decode, stdOut)
            if success and response.content and response.content[1] then
                local synthesis = response.content[1].text

                -- Create title from synthesis
                local title = synthesis:match("# ([^\n]+)") or sanitizeFilename(clipboardText)
                local timestamp = getTimestamp()
                local filename = string.format("%s-granola-%s.md", timestamp, title:gsub("^# ", ""))
                local filepath = obsidianPath .. filename

                -- Create content with frontmatter
                local frontmatter = createFrontmatter(title)
                local content = frontmatter .. synthesis .. "\n\n---\n\n## Full Transcript\n\n" .. clipboardText

                -- Write to file
                local file = io.open(filepath, "w")
                if file then
                    file:write(content)
                    file:close()
                    hs.alert.show("✅ Synthesized & saved to Obsidian")
                else
                    hs.alert.show("❌ Error saving file")
                end
            else
                hs.alert.show("❌ Claude API error")
                processGranolaNoteBasic()
            end
        else
            hs.alert.show("❌ Claude API failed")
            processGranolaNoteBasic()
        end
    end, {"-c", curlCommand}):start()
end

-- Bind hotkey
-- Hyper+O = Process with Claude synthesis
-- Hyper is typically Cmd+Ctrl+Alt+Shift (often mapped to Caps Lock via Karabiner-Elements)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "O", function()
    processGranolaNoteWithClaude()
end)

hs.alert.show("Granola → Obsidian automation loaded (Hyper+O)")
