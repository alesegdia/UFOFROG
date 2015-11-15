
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

-- some standard proxies
Image   = Proxy(function(k) return love.graphics.newImage('img/' .. k .. '.png') end)
SfxOGG  = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.ogg', 'static') end)
SfxMP3  = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.mp3', 'static') end)
SfxWAV  = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.wav', 'static') end)
MusicOGG = Proxy(function(k) return love.audio.newSource('music/' .. k .. '.ogg', 'stream') end)
MusicMP3 = Proxy(function(k) return love.audio.newSource('music/' .. k .. '.mp3', 'stream') end)

