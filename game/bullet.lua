

Bullet = Class:new()

function Bullet:init( cx, cy, angle )

	self.anim = newAnimation( love.graphics.newImage("media/tiro0.png"), 13, 30, 0, 0 )
	local pos = rotate_vector( 400 - self.anim:getWidth()/2, 400, cx, cy, angle )
	self.x = pos.x
	self.y = pos.y
	self.dir = normalize( pos.x - huevos.x, pos.y - huevos.y )
	self.speed = BULLET_SPEED
	self.angle = -angle

end

function Bullet:update( dt )

	self.x = self.x + self.dir.x * self.speed
	self.y = self.y + self.dir.y * self.speed
	self.anim:update(dt)
	return self.x > 800 or self.x < -100 or self.y > 700 or self.y < -100

end

function Bullet:draw()
	self.anim:draw(self.x, self.y, -self.angle, 1, 1, self.anim:getWidth()/2, self.anim:getHeight()/2)
	--drawBox( self )
end
