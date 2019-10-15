Canvas = {}
Canvas.__index = Canvas

function Canvas:new(canvasName, headerName)
    local ass = {}
    setmetatable(ass, Canvas)
    if not canvasName then
        sb.logError("No canvas given")
        return
    end
    ass.textStorage = {} -- array of strings
    ass.canvas = widget.bindCanvas(canvasName)
    ass.canvasName = canvasName
    ass.headerName = headerName
    ass.textSize = 7
    if not canvases then canvases = {} end -- setting up a global table
    canvases[#canvases+1] = canvasName
    _ENV[canvasName.."Canvas"] = ass
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
    self.tempStorage = nil -- same as above
    headerNameOverride[self.headerName] = nil -- ditto
    widget.setText(self.headerName, string.format("^#%s;%s^reset;", color:dark(1), labels[self.headerName].text)) -- reset name back to default. assume color exists.
    widget.setData(self.headerName, string.format("^#%s;%s^reset;", color:dark(1), labels[self.headerName].text))
end

function Canvas:clearText()
    self.textStorage = {}
    self.spcLayout = nil
    self.tempStorage = nil
    headerNameOverride[self.headerName] = nil
    widget.setText(self.headerName, string.format("^#%s;%s^reset;", color:dark(1), labels[self.headerName].text))
    widget.setData(self.headerName, string.format("^#%s;%s^reset;", color:dark(1), labels[self.headerName].text))
end

function Canvas:maxLines()
    local r = self.canvas:size()[2]/self.textSize
    if r ~= math.floor(r) then
        self:addText("Warning. Uneven lines. Change the vertical size of the canvas.")
    end
    return self.canvas:size()[2]/self.textSize
end

function Canvas:specialLayout(layoutName, tempStorage, newHeaderName, pages) -- [pages]
    --self.textStorage = {}
    self.spcLayout = layoutName -- < string. Use this for checks if the layout is OK to draw values from.
    self.tempStorage = tempStorage
    headerNameOverride[self.headerName] = newHeaderName
    widget.setText(self.headerName, string.format("^#%s;%s^reset;", color:dark(1), newHeaderName)) -- assume color exists
    widget.setData(self.headerName, string.format("^#%s;%s^reset;", color:dark(1), newHeaderName)) -- shitty starbound shit
    if pages then
        self.pages = pages
        self:setPage(1)
    end
end

function Canvas:setPage(a)
    if self.spcLayout and self.pages then
        if not self.pages[a] then
            return
        end
        self.textStorage = self.pages[a]
        local headerText = widget.getData(self.headerName)
        headerText = headerText:gsub("%b^;", "") -- remove color codes
        local start, stop = string.find(headerText, " %(%d+/%d+%)") -- returns the start/end positions of a ' (1/2)' page thing. Space included!
        if start then
            headerText = string.sub(headerText, 0, start-1)
        end
        local pageCounter = string.format(" (%i/%i)", a, #self.pages)
        headerText = headerText..pageCounter
        local text = string.format("^#%s;%s^reset;", color:dark(1), headerText)
        widget.setText(self.headerName, text) -- Add color managment. Simplest seems to be to remove all color codes, concatenate the string and re-add them.
        widget.setData(self.headerName, text)
    end
end
--[[
add a :page(int) function. as it stands, doing it command side would make it impossible to do, 
as using new lines would wipe temporary storage. adding a new storage medium for pages as an array 
of arrays of strings for lines would probably be best, with :page(int) just acting as a means to 
swipe through them. it's also dependant on the special layout.
it'd also be pretty intuitive to use as it'd take into account the context of the most recent listing 
into consideration if you catch my groove future me.
Add a page counter to the header
--]]