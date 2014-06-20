
Enemy = Class:new()

function Enemy:init( objx, objy, g0, g1 )

	self.active = true
	self.anim = newAnimation( love.graphics.newImage("bicho.png"), 56, 78, 0, -1 )
	self.anim:addFrame(42,0,42,78,0.1)		-- aleta izq
	self.anim:addFrame(84,0,42,78,0.1)		-- mordisco
	self.anim:addFrame(126,0,42,78,0.1)		-- aleta der
	self.anim:addFrame(84,0,42,78,0.1)		-- mordisco
	self.anim:setMode("bounce")

	self.angle = math.rad( love.math.random( g0, g1 ) - 90 )
	self.speed = ENEMY_SPEED

	local pos = rotate_vector( objx, objy-600, objx, objy, self.angle )
	self.x = pos.x
	self.y = pos.y
	self.dir = normalize( objx - pos.x, objy - pos.y )

end

function Enemy:update(dt)
	self.x = (self.x + self.dir.x * self.speed)
	self.y = (self.y + self.dir.y * self.speed)
	self.anim:update( dt, self.angle, 1, 1, self.anim:getWidth() / 2, self.anim:getHeight() / 2 )
	return self.y > 600
end



--function Enemy:update( dt )
