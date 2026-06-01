-- * Copyright 2026 P1KaChU337
-- * VK: https://vk.com/p1kachu337 | Telegram: @sh1zurz | GitHub: https://github.com/P1KaChU337 | Discord: p1kachu337
-- * 
-- * Licensed under the Apache License, Version 2.0 (the "License");
-- * you may not use this file except in compliance with the License.
-- * You may obtain a copy of the License at
-- *
-- *     http://www.apache.org/licenses/LICENSE-2.0
-- *
-- * Unless required by applicable law or agreed to in writing, software
-- * distributed under the License is distributed on an "AS IS" BASIS,
-- * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- * See the License for the specific language governing permissions and
-- * limitations under the License.

-- -------------------------------------------------

local pzgui = {}

-- -------------------------------------------------

local buffer = require("doubleBuffering")
local unicode = require("unicode")
local bit = require("bit32")
local computer = require("computer")
local pzguidigits = require("pzguidigits")


local buttons
local buttonID
local switches
local switchID
local searchFields
local searchFieldID

local colors = {
    textclr = 0xcccccc,
    textbtn = 0xffffff,
}

function pzgui.Init()
    buttons = {}
    buttonID = 0
    switches = {}
    switchID = 0
    searchFields = {}
    searchFieldID = 0
end

-- -------------------------------------------------

-- Braille characters are used to create a high-resolution grid of 2x4 dots
local function brailleChar(dots)
    return unicode.char(
        10240 +
        (dots[8] or 0) * 128 +
        (dots[7] or 0) * 64 +
        (dots[6] or 0) * 32 +
        (dots[4] or 0) * 16 +
        (dots[2] or 0) * 8 +
        (dots[5] or 0) * 4 +
        (dots[3] or 0) * 2 +
        (dots[1] or 0)
    )
end

-- Braille patterns for digits 0-9 and symbols
-- Импортировано из pzguidigits.lua
local digit_0_1, digit_0_2, digit_0_3, digit_0_4,
      digit_1_1, digit_1_2, digit_1_3, digit_1_4,
      digit_2_1, digit_2_2, digit_2_3, digit_2_4,
      digit_3_1, digit_3_2, digit_3_3, digit_3_4,
      digit_4_1, digit_4_2, digit_4_3, digit_4_4,
      digit_5_1, digit_5_2, digit_5_3, digit_5_4,
      digit_6_1, digit_6_2, digit_6_3, digit_6_4,
      digit_7_1, digit_7_2, digit_7_3, digit_7_4,
      digit_8_1, digit_8_2, digit_8_3, digit_8_4,
      digit_9_1, digit_9_2, digit_9_3, digit_9_4,
      sym_minus, sym_dot,
      button, button_push, 
      horizontal_line, vertical_line, vertical_line_up, vertical_line_down,
      corner,
      brail_fields = table.unpack(pzguidigits)

-- -------------------------------------------------

-- UTILS
local function centerText(text, totalWidth)
    local textLen = unicode.len(text)
    local pad = math.floor((totalWidth - textLen) / 2)
    if pad < 0 then pad = 0 end
    return string.rep(" ", pad) .. text
end

local function shortenTextCentered(text, maxLength)
    maxLength = maxLength or 12
    if unicode.len(text) > maxLength then
        text = unicode.sub(text, 1, maxLength - 3) .. "..."
    end
    return centerText(text, maxLength)
end

local function drawDigit(x, y, braill, color)
    buffer.drawText(x,     y,     color, brailleChar(braill[1]))
    buffer.drawText(x,     y + 1, color, brailleChar(braill[3]))
    buffer.drawText(x + 1, y,     color, brailleChar(braill[2]))
    buffer.drawText(x + 1, y + 1, color, brailleChar(braill[4]))
end

-- Level-based Braille maps for digits 0-9 and symbols
local braillMaps = {
    [1] = {
        [0] = digit_0_1,
        [1] = digit_1_1,
        [2] = digit_2_1,
        [3] = digit_3_1,
        [4] = digit_4_1,
        [5] = digit_5_1,
        [6] = digit_6_1,
        [7] = digit_7_1,
        [8] = digit_8_1,
        [9] = digit_9_1,
        ["-"] = sym_minus,
        ["."] = sym_dot,
    },
    [2] = {
        [0] = digit_0_2,
        [1] = digit_1_2,
        [2] = digit_2_2,
        [3] = digit_3_2,
        [4] = digit_4_2,
        [5] = digit_5_2,
        [6] = digit_6_2,
        [7] = digit_7_2,
        [8] = digit_8_2,
        [9] = digit_9_2,
        ["-"] = sym_minus,
        ["."] = sym_dot,
    },
    [3] = {
        [0] = digit_0_3,
        [1] = digit_1_3,
        [2] = digit_2_3,
        [3] = digit_3_3,
        [4] = digit_4_3,
        [5] = digit_5_3,
        [6] = digit_6_3,
        [7] = digit_7_3,
        [8] = digit_8_3,
        [9] = digit_9_3,
        ["-"] = sym_minus,
        ["."] = sym_dot,
    },
    [4] = {
        [0] = digit_0_4,
        [1] = digit_1_4,
        [2] = digit_2_4,
        [3] = digit_3_4,
        [4] = digit_4_4,
        [5] = digit_5_4,
        [6] = digit_6_4,
        [7] = digit_7_4,
        [8] = digit_8_4,
        [9] = digit_9_4,
        ["-"] = sym_minus,
        ["."] = sym_dot,
    },
}
-- END:UTILS

-- LEVELED LINES
function pzgui.drawHrzLine(x, y, length, level, color)
    local lineChar = level and horizontal_line[level] or horizontal_line[1]
    for i = 0, length - 1 do
        buffer.drawText(x + i, y, color, brailleChar(lineChar))
    end
end

function pzgui.drawVrtLine(x, y, length, level, color, isDirectionRight, isDirectionDown)
    level = math.max(1, math.min(level or 1, 4))
    local levelindex = (level - 1) * 2 + (isDirectionRight and 2 or 1)

    local bodyChar = vertical_line[isDirectionRight and 2 or 1]
    local capChar = isDirectionDown and vertical_line_down[levelindex] or vertical_line_up[levelindex]

    local capY = isDirectionDown and (y + length - 1) or y
    local bodyStart = isDirectionDown and y or (y + 1)
    local bodyEnd = isDirectionDown and (y + length - 2) or (y + length - 1)

    for i = bodyStart, bodyEnd do
        buffer.drawText(x, i, color, brailleChar(bodyChar))
    end
    buffer.drawText(x, capY, color, brailleChar(capChar))
end
-- END:LEVELED LINES

-- DIGITS
function pzgui.drawNumber(level, centerX, centerY, number, color, suffix, suffixColor)
    local digitWidth = 2
    centerY = centerY-1
    suffixColor = suffixColor or color
    
    -- Get the map for this level (default to level 1 if invalid)
    level = level or 1
    if level < 1 or level > 4 then level = 1 end
    local currentBraillMap = braillMaps[level]

    local digits = {}
    local widths = {}
    local strNum = tostring(number)

    for i = 1, #strNum do
        local ch = strNum:sub(i, i)
        local n = tonumber(ch)
        if n then
            table.insert(digits, currentBraillMap[n])
            table.insert(widths, digitWidth)
        elseif currentBraillMap[ch] then
            table.insert(digits, currentBraillMap[ch])
            if ch == "." then
                table.insert(widths, 1)
            else
                table.insert(widths, digitWidth)
            end
        end
    end

    local suffixWidth = suffix and #suffix or 0
    local totalWidth = 0
    for _, w in ipairs(widths) do totalWidth = totalWidth + w end
    totalWidth = totalWidth + (suffixWidth > 0 and (suffixWidth + 1) or 0)

    local startX = math.floor(centerX - totalWidth / 2)

    buffer.drawText(startX, centerY, colors.bg, string.rep(" ", totalWidth))

    local x = startX
    for i, digit in ipairs(digits) do   
        drawDigit(x, centerY, digit, color)
        x = x + widths[i]
    end

    if suffix and suffixWidth > 0 then
        buffer.drawText(x, centerY, suffixColor, suffix)
    end
end
-- END:DIGITS

-- CORNERS
function pzgui.drawCorner(x, y, width, height, background, foreground)
    buffer.drawRectangle(x, y, 1, 1, foreground, foreground, " ")
    buffer.drawRectangle(x + width - 1, y, 1, 1, foreground, foreground, " ")
    buffer.drawRectangle(x, y + height - 1, 1, 1, foreground, foreground, " ")
    buffer.drawRectangle(x + width - 1, y + height - 1, 1, 1, foreground, foreground, " ")
    -- Верхняя левая
    buffer.drawText(x, y, background, brailleChar(corner[1]))
    -- Верхняя правая
    buffer.drawText(x + width - 1, y, background, brailleChar(corner[2]))
    -- Нижняя левая
    buffer.drawText(x, y + height - 1, background, brailleChar(corner[3]))
    -- Нижняя правая
    buffer.drawText(x + width - 1, y + height - 1, background, brailleChar(corner[4]))
end

function pzgui.drawCorneredRect(x, y, width, height, background, foreground)
    buffer.drawRectangle(x, y, width, height, foreground, foreground, " ")
    buffer.drawRectangle(x + 1, y, width -2, height, background, foreground, " ")
    buffer.drawRectangle(x, y + 1, width, height -2, background, foreground, " ")

    -- Верхняя левая
    buffer.drawText(x, y, background, brailleChar(corner[1]))
    -- Верхняя правая
    buffer.drawText(x + width - 1, y, background, brailleChar(corner[2]))
    -- Нижняя левая
    buffer.drawText(x, y + height - 1, background, brailleChar(corner[3]))
    -- Нижняя правая
    buffer.drawText(x + width - 1, y + height - 1, background, brailleChar(corner[4]))
end
-- END:CORNERS

-- SWITCH
local function drawSwitch(x, y, width, pipePos, state, activeClr, passiveClr, pipeClr, bgClr)
    local activeCol = activeClr or 0x0088ff
    local passiveCol = passiveClr or 0x444444
    local pipeCol = pipeClr or 0xFFFFFF

    if bgCol then
        buffer.drawRectangle(x, y, width, 1, bgCol, 0, " ")
    end 

    -- Левый край
    if pipePos > 1 then
        buffer.drawText(x, y, activeCol, "◖")
    end
    -- Правый край
    if pipePos < width - 1 then
        buffer.drawText(x + width - 1, y, passiveCol, "◗")
    end
    -- Фон
    if pipePos - 1 > 0 then
        buffer.drawRectangle(x + 1, y, pipePos - 1, 1, activeCol, 0, " ")
    end
    if width - pipePos - 1 > 0 then
        buffer.drawRectangle(x + pipePos, y, width - pipePos - 1, 1, passiveCol, 0, " ")
    end
    -- Ползунок
    buffer.drawText(x + pipePos - 1, y, pipeCol, "◖")
    buffer.set(x + pipePos, y, pipeCol, pipeCol, " ")
    buffer.drawText(x + pipePos + 1, y, pipeCol, "◗")
end

function pzgui.drawSwitch(x, y, width, state, activeClr, passiveClr, pipeClr, bgClr, id)
    local swID
    if id ~= nil then
        swID = id
    else
        switchID = switchID + 1
        swID = switchID
    end

    local pipePos = state and math.max(1, width - 2) or 1
    drawSwitch(x, y, width, pipePos, state, activeClr, passiveClr, pipeClr, bgClr)
    switches[swID] = {
        x = x,
        y = y,
        width = width,
        state = state,
        pipePos = pipePos,
        activeClr = activeClr,
        passiveClr = passiveClr,
        pipeClr = pipeClr,
        bgClr = bgClr,
    }
    return swID
end

function pzgui.lockSwitch(ID)
    local sw = switches[ID]
    if sw and not sw.isLocked then
        sw.isLocked = true
    end
end

function pzgui.unlockSwitch(ID)
    local sw = switches[ID]
    if sw and sw.isLocked then
        sw.isLocked = false
    end
end

function pzgui.toggleSwitch(x, y)
    for swID, sw in pairs(switches) do
        if sw and not sw.isLocked and x >= sw.x and x <= sw.x + sw.width - 1 and y == sw.y then
            sw.state = not sw.state
            local currentPos = sw.pipePos or 1
            local targetPos = sw.state and math.max(1, sw.width - 2) or 1
            local step = (targetPos > currentPos) and 1 or -1
            repeat
                currentPos = currentPos + step
                sw.pipePos = currentPos
                drawSwitch(sw.x, sw.y, sw.width, sw.pipePos, sw.state, sw.activeClr, sw.passiveClr, sw.pipeClr, sw.bgClr)
                buffer.drawChanges()
                os.sleep(0.02)
            until sw.pipePos == targetPos
            return swID, sw.state
        end
    end
    return false
end
-- END:SWITCH

-- SEARCH FIELD
searchFields = {}

local function drawSearchField(field)
    local fieldColor = field.clr
    local fieldBgColor = field.bgclr
    local placeholderColor = field.placeholderClr
    local fieldTextColor = 0xffffff

    buffer.drawRectangle(field.x, field.y, field.width, 1, fieldColor, fieldBgColor, " ")
    buffer.drawRectangle(field.x + 1, field.y - 1, field.width - 2, 1, fieldColor, fieldBgColor, brailleChar(brail_fields[6]))
    buffer.drawRectangle(field.x + 1, field.y + 1, field.width - 2, 1, fieldColor, fieldBgColor, brailleChar(brail_fields[5]))
    buffer.drawText(field.x, field.y - 1, fieldColor, brailleChar(brail_fields[1]))
    buffer.drawText(field.x, field.y + 1, fieldColor, brailleChar(brail_fields[4]))
    buffer.drawText(field.x + field.width - 1, field.y - 1, fieldColor, brailleChar(brail_fields[2]))
    buffer.drawText(field.x + field.width - 1, field.y + 1, fieldColor, brailleChar(brail_fields[3]))

    local visibleText
    local maxVisible = field.width - 2
    local startX, startY = field.x + 1, field.y

    if not field.active then
        if field.text == "" then
            buffer.drawText(startX, startY, placeholderColor, centerText(field.placeholder, field.width))
        else
            buffer.drawText(startX, startY, placeholderColor, shortenTextCentered((field.hidden and string.rep("*", unicode.len(unicode.sub(field.text, field.scrollOffset + 1, field.scrollOffset + maxVisible))) or field.text), maxVisible))
        end
    else
        if field.cursorPos - field.scrollOffset > maxVisible then
            field.scrollOffset = field.cursorPos - maxVisible
        elseif field.cursorPos <= field.scrollOffset then
            field.scrollOffset = math.max(0, field.cursorPos - 1)
        end

        if field.hidden then
            visibleText = string.rep("*", unicode.len(unicode.sub(field.text, field.scrollOffset + 1, field.scrollOffset + maxVisible)))
        else
            visibleText = unicode.sub(field.text, field.scrollOffset + 1, field.scrollOffset + maxVisible)
        end

        buffer.drawText(startX, startY, fieldTextColor, visibleText)

        if field.cursorVisible then
            local cursorX = startX + (field.cursorPos - 1 - field.scrollOffset)
            buffer.drawText(cursorX, startY, fieldTextColor, "|")
        end
    end
end

local function drawAllFields()
    for _, f in pairs(searchFields) do
        drawSearchField(f)
    end
    buffer.drawChanges()
end

local function deactivateAllFields()
    for _, f in pairs(searchFields) do
        f.active = false
        f.cursorVisible = false
    end
end

local function getActiveField()
    for id, f in pairs(searchFields) do
        if f.active then
            return f, id
        end
    end
    return nil, nil
end

local function clampCursor(field)
    field.cursorPos = math.max(1, math.min(field.cursorPos, unicode.len(field.text) + 1))
    local maxVisible = field.width - 2
    if field.cursorPos - field.scrollOffset > maxVisible then
        field.scrollOffset = field.cursorPos - maxVisible
    elseif field.cursorPos <= field.scrollOffset then
        field.scrollOffset = math.max(0, field.cursorPos - 1)
    end
end

function pzgui.createSearchField(x, y, width, placeholder, hidden, clr, bgclr, placeholderClr, numericOnly, id)
    local fieldID = id or (searchFieldID + 1)
    if fieldID > searchFieldID then
        searchFieldID = fieldID
    end

    searchFields[fieldID] = {
        x = x,
        y = y,
        width = width,
        placeholder = placeholder or "Введите текст...",
        text = "",
        cursorPos = 1,
        scrollOffset = 0,
        cursorVisible = false,
        lastBlink = computer.uptime(),
        active = false,
        hidden = hidden and true or false,
        numericOnly = numericOnly and true or false,
        clr = clr or 0x444444,
        bgclr = bgclr or 0xcccccc,
        placeholderClr = placeholderClr or 0xececec,
    }

    return fieldID
end

function pzgui.removeSearchField(id)
    if searchFields[id] then
        searchFields[id] = nil
    end
end

function pzgui.clearSearchFields()
    for id in pairs(searchFields) do
        searchFields[id] = nil
    end
end

function pzgui.drawSearchFields()
    drawAllFields()
end

function pzgui.updateSearchFieldBlink()
    local redraw = false
    for _, f in pairs(searchFields) do
        if f.active and computer.uptime() - f.lastBlink >= 0.5 then
            f.cursorVisible = not f.cursorVisible
            f.lastBlink = computer.uptime()
            redraw = true
        end
    end
    if redraw then
        drawAllFields()
    end
end

function pzgui.handleSearchFieldEvent(eventData)
    if not eventData or type(eventData) ~= "table" then
        return false
    end

    local eventType = eventData[1]
    if eventType == "touch" then
        local _, _, x, y = table.unpack(eventData)
        local touchedField = nil

        for id, f in pairs(searchFields) do
            if y == f.y and x >= f.x and x <= f.x + f.width - 1 then
                touchedField = id
                break
            end
        end

        if touchedField then
            for id, f in pairs(searchFields) do
                f.active = (id == touchedField)
                f.cursorVisible = f.active
                if f.active then
                    f.lastBlink = computer.uptime()
                end
            end
            drawAllFields()
            return true
        else
            deactivateAllFields()
            drawAllFields()
            return false
        end
    elseif eventType == "key_down" then
        local _, _, char, code = table.unpack(eventData)
        local field, fieldId = getActiveField()
        if not field then
            return false
        end

        if code == 14 then -- Backspace
            if field.cursorPos > 1 then
                field.text = unicode.sub(field.text, 1, field.cursorPos - 2) .. unicode.sub(field.text, field.cursorPos)
                field.cursorPos = field.cursorPos - 1
            end
        elseif code == 203 then -- arrow left
            field.cursorPos = math.max(1, field.cursorPos - 1)
        elseif code == 205 then -- arrow right
            field.cursorPos = math.min(unicode.len(field.text) + 1, field.cursorPos + 1)
        elseif code == 28 then -- Enter
            field.active = false
            field.cursorVisible = false
            clampCursor(field)
            drawAllFields()
            return fieldId, field.text
        elseif char and char > 0 then -- printable Unicode
            local c = unicode.char(char)
            if field.numericOnly then
                if c:match("%d") then
                    field.text = unicode.sub(field.text, 1, field.cursorPos - 1) .. c .. unicode.sub(field.text, field.cursorPos)
                    field.cursorPos = field.cursorPos + 1
                end
            else
                field.text = unicode.sub(field.text, 1, field.cursorPos - 1) .. c .. unicode.sub(field.text, field.cursorPos)
                field.cursorPos = field.cursorPos + 1
            end
        end

        clampCursor(field)
        drawAllFields()
        return true
    end

    return false
end

function pzgui.getSearchFieldText(id)
    local field = searchFields[id]
    return field and field.text
end

function pzgui.setSearchFieldText(id, text)
    local field = searchFields[id]
    if field then
        field.text = tostring(text or "")
        clampCursor(field)
    end
end
-- END:SEARCH FIELD

--  BUTTONS
local function animatedButton(push, x, y, text, tx, ty, length, time, clearWidth, color, textcolor)
    local btn = push == 1 and button or button_push
    local bgColor = color or 0x059bff
    local tColor = textcolor or colors.textbtn
    local clear = clearWidth or length
    if not text then tx = x  end
    local ftext = text or "* Клик *"
    local ftx = tx or x
    local fty = ty or y + 1
    local ftime = time or 0.3

    if push == 1 then
        buffer.drawRectangle(x, y + 1, length, 1, bgColor, 0, " ")
        buffer.drawText(ftx, fty, tColor, shortenTextCentered(ftext, length))
    end
    -- Левая граница
    buffer.drawText(x - 1, y, bgColor, brailleChar(btn[4]))
    buffer.drawText(x - 1, y + 1, bgColor, brailleChar(btn[3]))
    buffer.drawText(x - 1, y + 2, bgColor, brailleChar(btn[5]))

    -- Правая граница
    buffer.drawText(x + length, y, bgColor, brailleChar(btn[2]))
    buffer.drawText(x + length, y + 1, bgColor, brailleChar(btn[3]))
    buffer.drawText(x + length, y + 2, bgColor, brailleChar(btn[6]))

    -- Центральная линия
    for i = 0, length - 1 do
        buffer.drawText(x + i, y,     bgColor, brailleChar(btn[1]))
        buffer.drawText(x + i, y + 2, bgColor, brailleChar(btn[7]))
    end

    if push == 0 and clearWidth and clearWidth > length then
        buffer.drawText(x - 2, y + 1, tColor, " ")
        buffer.drawText(x - 2, y, tColor, " ")
        buffer.drawText(x - 2, y + 2, tColor, " ")
        buffer.drawText(x + length + 1, y + 1, tColor, " ")
        buffer.drawText(x + length + 1, y, tColor, " ")
        buffer.drawText(x + length + 1, y + 2, tColor, " ")
        buffer.drawRectangle(x, y + 1, length, 1, bgColor, 0, " ")
        buffer.drawText(ftx, fty, tColor, shortenTextCentered(ftext, length))
    end

    if push == 0 then 
        buffer.drawChanges()
        os.sleep(ftime) 
    end
end

function pzgui.drawButton(x, y, color, text, textcolor, length, id)
    local btnID
    if id ~= nil then
        btnID = id
    else
        buttonID = buttonID + 1
        btnID = buttonID
    end
    -- local button = id or (buttonID + 1)
    local length = length or unicode.len(text) + 2
    local clearWidth = length + 2
    animatedButton(1, x, y, text, nil, nil, length, nil, clearWidth, color, textcolor)
    buttons[btnID] = {
        x = x,
        y = y,
        color = color or 0x059bff,
        text = text,
        textcolor = textcolor or colors.textbtn,
        length = length,
        isLocked = false,
    }
    return btnID
end

function pzgui.btnLock(ID)
    local btn = buttons[ID]
    if btn and not btn.isLocked then
        btn.isLocked = true
    end
end

function pzgui.btnUnlock(ID)
    local btn = buttons[ID]
    if btn and btn.isLocked then
        btn.isLocked = false
    end
end

function pzgui.handleButtonPress(x, y)
    for btnID, btn in pairs(buttons) do
        if btn and not btn.isLocked then
            local length = btn.length or unicode.len(btn.text) + 2
            if x >= btn.x - 1 and x <= btn.x + length and y >= btn.y and y <= btn.y + 2 then
                animatedButton(0, btn.x, btn.y, btn.text, nil, nil, length, 0.3, length + 2, btn.color, btn.textcolor)
                animatedButton(1, btn.x, btn.y, btn.text, nil, nil, length, nil, length + 2, btn.color, btn.textcolor)
                buffer.drawChanges()
                return btnID
            end
        end
    end
    return false
end
-- END:BUTTONS

-- -------------------------------------------------

return pzgui