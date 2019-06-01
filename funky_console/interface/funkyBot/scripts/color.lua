Color = {}

function Color:new(color)
    self._index = self

    --local savedColor = status.statusProperty("apolloColor", "E9E9E9") <- this shit's bad. Do an array of two color arrays for lightest/darkest color (GRADIENTS!!!) 
    local savedColor = color --{{200,200,200}, {30,30,30}}
    local a = {}
    for col=0,3 do
        local color = {}
        for i=1,3 do
            color[i] = math.floor(savedColor[1][i] + ((savedColor[2][i]-savedColor[1][i])*(col/3))) -- Gradients
        end -- Adding color etc
        a[#a+1] = color
    end
    self.colors = a -- quad array of rgb colors
    local b = {}
    for i=1, #self.colors do
        local rgb = self.colors[i]
        local str = ""
        for j=1, #rgb do
            str = str..hexConverter(rgb[j])
        end 
        b[#b+1] = str
    end
    self.colorsHex = b
    return self
end

function Color:lightest(a)
    if a then -- im too lazy to edit my existing system so i'll just do this shit
        return self.colorsHex[1]
    end
    return self.colors[1]
end

function Color:light(a)
    if a then
        return self.colorsHex[2]
    end
    return self.colors[2]
end

function Color:dark(a)
    if a then
        return self.colorsHex[3]
    end
    return self.colors[3]
end

function Color:darkest(a)
    if a then
        return self.colorsHex[4]
    end
    return self.colors[4]
end

function Color:updateColors(color)
    local savedColor = color --{{200,200,200}, {30,30,30}}
    local a = {}
    for col=0,3 do
        local color = {}
        for i=1,3 do
            color[i] = math.floor(savedColor[1][i] + ((savedColor[2][i]-savedColor[1][i])*(col/3))) -- Gradients
        end -- Adding color etc
        a[#a+1] = color
    end
    self.colors = a -- quad array of rgb colors
    local b = {}
    for i=1, #self.colors do
        local rgb = self.colors[i]
        local str = ""
        for j=1, #rgb do
            str = str..hexConverter(rgb[j])
        end 
        b[#b+1] = str
    end
    self.colorsHex = b
end

function rawHexToDec(_hex)
	if type(_hex) == "string" then
		local h = _hex:lower()
		local charray = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
		local total = 0
		for i = 1, h:len(), 1 do
			local c = h:sub(h:len() - i + 1, - 1 * i)
			for v, x in ipairs(charray) do
				if c == x then
					total = total + ((v - 1) * 16 ^ (i - 1))
				end
			end
		end
		return total
	else
		return 0
	end
end

function hexConverter(input)
    local hexCharacters = '0123456789abcdef'
    local output = ''
    while input > 0 do
        local mod = math.fmod(input, 16)
        output = string.sub(hexCharacters, mod+1, mod+1) .. output
        input = math.floor(input / 16)
    end
    if output == '' then
        output = '0'
    end
    if string.len(output) == 1 then 
        output = "0"..output
    end
    return output
end

function hexToRGB(_hex)
	if type(_hex) == "string" then
		local h = _hex
		local r, g, b = 0, 0, 0
		if h:len() == 6 then
			local red = h:sub(1, 2)
			local green = h:sub(3, - 3)
			local blue = h:sub( - 2, - 1)
			r = rawHexToDec(red)
			g = rawHexToDec(green)
			b = rawHexToDec(blue)
			return {r, g, b}
		elseif h:len() == 8 then
			return {0, 0, 0}
		end
	else
		return {0, 0, 0}
	end
end