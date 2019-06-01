Canvas = {}
Canvas.__index = Canvas

function Canvas:new(canvasName)
    local ass = {}
    setmetatable(ass, Canvas)
    if not canvasName then
        sb.logError("No canvas given")
        return
    end
    ass.textStorage = {} -- array of strings
    ass.canvas = widget.bindCanvas(canvasName)
    ass.canvasName = canvasName
    ass.textSize = 7
    return ass
end

function Canvas:update()
    self.canvas:clear()
    for i=1, #self.textStorage do
        self.canvas:drawText(
            ">"..self.textStorage[i],
            {
                position = {0, self.textSize*(#self.textStorage-(i-1))},
                horizontalAnchor = "left", -- left, mid, right
                verticalAnchor = "top", -- top, mid, bottom
                wrapWidth = nil -- wrap width in pixels or nil
            },
            self.textSize,
            color:light()
        )
    end
end

function Canvas:addText(txt)
    if #self.textStorage == self.canvas:size()[2]/self.textSize then
        table.remove(self.textStorage, 1)
    end
    self.textStorage[#self.textStorage+1] = txt and txt or "" -- failsaving just in case
    self.spcLayout = nil -- Means adding a line to an already specially prepared layout offsets it vertically, making it no longer okay.
end

function Canvas:clearText()
    self.textStorage = {}
end

function Canvas:maxLines()
    local r = self.canvas:size()[2]/self.textSize
    if r ~= math.floor(r) then
        self:addText("Warning. Uneven lines. Change the vertical size of the canvas.")
    end
    return self.canvas:size()[2]/self.textSize
end

function Canvas:specialLayout(layoutName)
    self.spcLayout = layoutName -- < string. Use this for checks if the layout is OK to draw values from.
end