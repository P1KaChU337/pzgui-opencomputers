local pzgui = require("pzgui")
local buffer = require("doubleBuffering")
local unicode = require("unicode")
local bit = require("bit32")
local event = require("event")

buffer.setResolution(160, 50)
buffer.clear(0xcccccc)

pzgui.Init()
local btn1 = pzgui.drawButton(10, 10, 0xc637ff, "Нажми на меня", 0xffffff, 19)
local btn2 = pzgui.drawButton(10, 13, 0xc637ff, "Мяв", 0xffffff, nil)
local btn7 = pzgui.drawButton(15, 13, 0xc637ff, "Nya", 0xffffff, nil, 7)
local btn3 = pzgui.drawButton(24, 13, 0xc637ff, "Нян", 0xffffff, nil)
local btn4 = pzgui.drawButton(10, 16, 0xc637ff, "Разблокировать все", 0xffffff, 19)
local btn5 = pzgui.drawButton(10, 19, 0xc637ff, "Заблокировать все", 0xffffff, 19)
local btn6 = pzgui.drawButton(38, 15, 0xff5f37, "reboot", 0xffffff, nil)
buffer.drawText(36, 23, 0x000000, "TEST LV1:")
pzgui.drawNumber(1, 55, 23, "0123456789", 0x000000)
buffer.drawText(36, 23+3, 0x000000, "TEST LV2:")
pzgui.drawNumber(2, 55, 23+3, "0123456789", 0x000000)
buffer.drawText(36, 23+6, 0x000000, "TEST LV3:")
pzgui.drawNumber(3, 55, 23+6, "0123456789", 0x000000)
buffer.drawText(36, 23+9, 0x000000, "TEST LV4:")
pzgui.drawNumber(4, 55, 23+9, "0123456789", 0x000000)

pzgui.drawHrzLine(45, 26+1, 20, 1, 0x000000)
pzgui.drawHrzLine(45, 23+1, 20, 2, 0x000000)
pzgui.drawHrzLine(45, 29+1, 20, 3, 0x000000)
pzgui.drawHrzLine(45, 32+1, 20, 4, 0x000000)

pzgui.drawVrtLine(34, 22, 12, 1, 0x000000, true, false)
pzgui.drawVrtLine(33, 22, 12, 1, 0x000000, false, true)
pzgui.drawVrtLine(34-2-1, 22, 12, 2, 0x000000, true, false)
pzgui.drawVrtLine(33-2-1, 22, 12, 2, 0x000000, false, true)
pzgui.drawVrtLine(34-4-1-1, 22, 12, 3, 0x000000, true, false)
pzgui.drawVrtLine(33-4-1-1, 22, 12, 3, 0x000000, false, true)
pzgui.drawVrtLine(34-6-1-1-1, 22, 12, 4, 0x000000, true, false)
pzgui.drawVrtLine(33-6-1-1-1, 22, 12, 4, 0x000000, false, true)

pzgui.drawVrtLine(34, 35, 12, 1, 0x000000, false, true)
pzgui.drawVrtLine(33, 35, 12, 1, 0x000000, false, true)
pzgui.drawVrtLine(34-2-1, 35, 12, 2, 0x000000, false, true)
pzgui.drawVrtLine(33-2-1, 35, 12, 2, 0x000000, false, true)
pzgui.drawVrtLine(34-4-1-1, 35, 12, 3, 0x000000, false, true)
pzgui.drawVrtLine(33-4-1-1, 35, 12, 3, 0x000000, false, true)
pzgui.drawVrtLine(34-6-1-1-1, 35, 12, 4, 0x000000, false, true)
pzgui.drawVrtLine(33-6-1-1-1, 35, 12, 4, 0x000000, false, true)


buffer.drawRectangle(55, 6, 24, 12, 0xc637ff, 0xcccccc, " ")
pzgui.drawCorner(55, 6, 24, 12, 0xc637ff, 0xcccccc)
pzgui.drawCorneredRect(55+25, 6, 24, 12, 0xf5fd90, 0xcccccc) 

pzgui.drawSwitch(38, 13, 6, true)
pzgui.drawSwitch(38, 11, 6, false)
pzgui.drawSwitch(55, 11, 6, false)

local field1 = pzgui.createSearchField(
    82, 10, 20,
    "Введите текст...",    -- placeholder
    false,                 -- hidden
    0x444444,              -- цвет рамки
    0xf5fd90,              -- фон
    0xececec,              -- placeholder цвет
    false                  -- numericOnly
)

local field2 = pzgui.createSearchField(
    82, 13, 20,
    "Мяу мяу?...",    -- placeholder
    false,                 -- hidden
    0x444444,              -- цвет рамки
    0xf5fd90,              -- фон
    0xececec,              -- placeholder цвет
    false                  -- numericOnly
)

pzgui.drawSearchFields()

buffer.drawChanges()

local function pressedSwitch(swID, state)
    buffer.drawText(33, 24-3, 0x000000, "Переключатель ")
    pzgui.drawNumber(4, 48, 24-3, swID, 0x000000)
    buffer.drawText(33+5, 24-3, 0x000000, " теперь ")
    buffer.drawText(33+5+9*6, 24-3, 0x000000, state and "ВКЛ" or "ВЫКЛ")
    buffer.drawChanges()
end

local function pressedBtn(btnID)
    if not btnID then return end
    if btnID == 1 then
        buffer.drawText(33, 20-3, 0x000000, ":3")
    elseif btnID == 2 then
        buffer.drawText(33, 21-3, 0x000000, "Мяв!")
        pzgui.btnLock(btn3)
    elseif btnID == 7 then
    elseif btnID == 3 then
        buffer.drawText(33, 22-3, 0x000000, "Нян!")
    elseif btnID == 4 then
        pzgui.btnUnlock(btn1)
        pzgui.btnUnlock(btn2)
        pzgui.btnUnlock(btn3)
    elseif btnID == 5 then
        pzgui.btnLock(btn1)
        pzgui.btnLock(btn2)
        pzgui.btnLock(btn3)
    elseif btnID == 6 then
        os.execute("reboot")
    end
    buffer.drawText(33, 23-3, 0x000000, "Нажата кнопка: ")
    pzgui.drawNumber(4, 48, 23-3, btnID, 0x000000)
    buffer.drawChanges()
end


while true do
    local eventData = {event.pull(0.05)}
    local eventType = eventData[1]
    pzgui.updateSearchFieldBlink()
    local fieldResult, fieldText = pzgui.handleSearchFieldEvent(eventData)

    if type(fieldResult) == "number" then
        if fieldResult == field1 then
            buffer.drawText(105, 10, 0x000000, "Поле 1 отправило: " .. (fieldText or ""))
        elseif fieldResult == field2 then
            buffer.drawText(105, 13, 0x000000, "Мяу 2 мяумяу: " .. (fieldText or ""))
        end
        buffer.drawChanges()
    elseif fieldResult then
        -- событие обработано полем поиска, ничего больше не делаем
    elseif eventType == "touch" then
        local _, _, x, y, button, uuid = table.unpack(eventData)

        pressedBtn(pzgui.handleButtonPress(x, y))
        pzgui.toggleSwitch(x, y)
    end
end
