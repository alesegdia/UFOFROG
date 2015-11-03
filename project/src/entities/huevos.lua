
require (LIBRARYPATH .. 'class')
require (LIBRARYPATH .. 'AnAL')

Huevos = Class:new()

function Huevos:init()

	self.x = HUEVOS_X
	self.y = HUEVOS_Y
	self.scale = 1
	self.yoffset = 0
	self.xoffset = 0

	self.list = {}

	for i=0,1 do
		for j=i,2 do
			local animat = newAnimation( Image.huevo, 42, 42, 0.1, -1 )
			animat:addFrame(0,0,42,42,0.1)
			animat:addFrame(42,0,42,42,0.1)
			animat:addFrame(82,0,42,42,0.1)
			animat:addFrame(0,0,42,42,1)
			animat:addFrame(42,0,42,42,0.1)
			animat:addFrame(0,0,42,42,0.1)
			animat:addFrame(82,0,42,42,0.1)
			animat:addFrame(0,0,42,42,0.6)
			animat:addFrame(82,0,42,42,0.1)
			animat:addFrame(0,0,42,42,0.25)
			animat:setMode("bounce")
			local xoff, yoff
			xoff = 30
			yoff = 28
			local huevo = { x = - 64 + self.x + j * xoff + (1-i) * 15, y = self.y - i * yoff, anim = animat }
			huevo.anim:update( math.random(0,10) )
			table.insert( self.list, huevo )
		end
	end

end

function Huevos:eclosionar()
	for k,v in pairs(self.list) do
		v.anim = newAnimation(Image.huevo_out, 28, 32, 0.1, -1 )
		v.anim:addFrame(0, 0, 28, 32, 0.8)
		v.anim:addFrame(28, 0, 28, 32, 0.05)
		v.anim:addFrame(0, 0, 28, 32, 0.05)
		v.anim:addFrame(28, 0, 28, 32, 0.05)
		v.anim:addFrame(0, 0, 28, 32, 1.2)
		v.anim:addFrame(28, 0, 28, 32, 0.05)
	end
end

function Huevos:update(dt)

	for k,huevo in pairs(self.list) do
		huevo.anim:update(dt)
	end

end


function Huevos:draw()
	for k,huevo in pairs(self.list) do
		huevo.anim:draw( huevo.x+self.xoffset, huevo.y +self.yoffset, 0, self.scale, self.scale )
	end
end

function Huevos:dropEgg() 
	table.remove( self.list )

end

function Huevos:remainingEggs()
	return #self.list
end

function Huevos:setScale(s)
	self.scale = s
end

function Huevos:setOffset(x,y)
	self.yoffset = x
	self.xoffset = y
end
