
Explosion = Class:new()

function Explosion:init(x, y)

	self.anim = newAnimation( love.graphics.newImage("explosion.png"), 64, 64, 0.08, 5 )
	self.anim:setMode("once")
	self.anim:play()
	self.x = x
	self.y = y

end


function Explosion:update(dt)
	self.anim:update(dt)
	return not self.anim.playing
end

function Explosion:draw()
	self.anim:draw(self.x, self.y)
end
