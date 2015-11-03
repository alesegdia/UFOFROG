
local json = require(LIBRARYPATH.."dkjson")

local util = {

	--local f,err = io.open(path,"r")
	--if not f then return print(err) end
	--f:close()
  json2table = function( path )
	local contents,size = love.filesystem.read(path)
	local tbl = json.decode(contents) --f:read("*all"))
	return tbl
  end,

  table2json = function( path, tbl )
	local f,err = io.open(path, "w+")
	if not f then return print(err) end
	f:write(json.encode(tbl))
	f:close()
	return true
  end,

  sign = function( n )
	if n < 0 then return -1 else return 1 end
  end

}

return util
