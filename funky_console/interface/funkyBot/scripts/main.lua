require("/scripts/vec2.lua")
require("/scripts/util.lua")
require("/scripts/rect.lua")
require("/interface/funkyBot/scripts/color.lua")
require("/interface/funkyBot/scripts/commands.lua")
require("/interface/funkyBot/scripts/canvas.lua")

function init()
    headerNameOverride = {} -- Used for text in header widgets for canvases. Special layouts have the ability to override the name should the need arise
    local a = status.statusProperty("funkyBotColor", {{200,200,200}, {60,60,60}})
    color = Color:new(a)
    setInterfaceColors()
    Canvas:new("command", "command_label")
    Canvas:new("misc", "misc_list_label")
    widget.focus("textInput")
end

function update(dt)
    for i, canvasName in ipairs(canvases) do
        _ENV[canvasName.."Canvas"]:update()
    end
end

function uninit()

end

function sendCommand()
    local str = widget.getText("textInput")
    local args = split(str, " ") -- splits the string into a table with spaces separating the arguments: hello world -> {"hello", "world"}
    local command = commands[args[1]]
    if command then
        table.remove(args,1) -- removes the 
        a, b = pcall(command.func, args)
        if not a then
            commandCanvas:addText("Error! Check the logs") -- error logging
            sb.logError(b)
        end
    else
        commandCanvas:addText("Command doesn't exist. Use 'help' to list all commands.")
    end
    widget.setText("textInput", "")
end

function setInterfaceColors()
    if not color then
        sb.logError("color class doesn't exist")
        return
    end
    labels = { -- made it global as canvas use it for default texts
        interface_name = {text = "Funky Bot", color = color:light(1)},
        command_label = {text = "Commands", color = color:dark(1)},
        misc_list_label = {text = "Misc", color = color:dark(1)},
        OKButton = {text="OK", color=color:dark(1)} -- clever use of my own shit yatta
    }
    local images = {
        body = {img = "/interface/funkyBot/images/body.png", color = color:darkest(1)},
        header = {img = "/interface/funkyBot/images/bar_full.png", color = color:lightest(1)},
        footer = {img = "/interface/funkyBot/images/bar_full.png", color = color:light(1)},
        command_header = {img = "/interface/funkyBot/images/command_header.png", color = color:light(1)},
        command_bg = {img = "/interface/funkyBot/images/command_bg.png", color = color:dark(1)},
        misc_list_header = {img = "/interface/funkyBot/images/misc_list_header.png", color = color:light(1)},
        misc_list_bg = {img = "/interface/funkyBot/images/misc_list_bg.png", color = color:dark(1)},
        input_bg = {img = "/interface/funkyBot/images/input_bg.png", color = color:dark(1)}
    }
    for widgetName, params in pairs(labels) do
        local text = string.format("^#%s;%s^reset;", params.color, headerNameOverride[widgetName] and headerNameOverride[widgetName] or params.text) -- override takes priority over the default name
        widget.setData(widgetName, text) -- override takes priority over the default name)
        widget.setText(widgetName, text) -- override takes priority over the default name
    end
    for widgetName, params in pairs(images) do
        widget.setImage(widgetName, string.format("%s?setcolor=%s", params.img, params.color))
    end
    local buttonImages = {
        base = "/interface/funkyBot/images/send_bttn.png?setcolor="..color:light(1),
        hover = "/interface/funkyBot/images/send_bttn.png?setcolor="..color:lightest(1),
        pressed = "/interface/funkyBot/images/send_bttn.png?setcolor="..color:dark(1),
        disabled = "/assetmissing.png",
    }
    widget.setButtonImages("OKButton", buttonImages)
end

function split(pString, pPattern)
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
	   if s ~= 1 or cap ~= "" then
	  table.insert(Table,cap)
	   end
	   last_end = e+1
	   s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
	   cap = pString:sub(last_end)
	   table.insert(Table, cap)
	end
	return Table
end

function removeHexColors(txt)
	return string.gsub(txt, "%b^;", "")
end

function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end