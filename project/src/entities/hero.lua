
require (LIBRARYPATH .. 'class')
require (LIBRARYPATH .. 'AnAL')
require (LIBRARYPATH .. 'razzmathazz')

Hero = Class:new()

function Hero:init( )

	self.active = true
	self.startx = HERO_X_START
	self.starty = HERO_Y_START
	self.x = self.startx
	self.y = self.starty
	self.speed = HERO_SPEED
	self.angle = HERO_START_ANGLE
	self.last_shot = 0

	self.anim = newAnimation( Image.ranamadre, 60, 42, 0.1, -1 )
	self.anim:addFrame(0, 0, 60, 42, 1)
	self.anim:addFrame(60, 0, 60, 42, 0.1)
	self.anim:addFrame(0, 0, 60, 42, 0.1)
	self.anim:addFrame(60, 0, 60, 42, 0.1)
	self.anim:addFrame(0, 0, 60, 42, 0.8)
	self.anim:addFrame(60, 0, 60, 42, 0.1)
	self.anim:addFrame(0, 0, 60, 42, 1)
	self.anim:addFrame(60, 0, 60, 42, 0.1)
	self.anim:setMode("bounce")

end

function Hero:update(dt,rx,ry)

	-- move update
	local step = HERO_MOVE_RATE
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then self.angle = self.angle - step
	elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then self.angle = self.angle + step end

	-- shot update
	local do_shoot = false
	if love.keyboard.isDown("space") then
		do_shoot = true
	end

	self.last_shot = self.last_shot - dt
	if do_shoot and self.last_shot <= 0 then
		player_shot()
		self.last_shot = HERO_SHOOT_RATE
	end

	-- self.rotation update
	self.anim:update(dt)
	if math.abs(self.angle) > math.pi/2-0.1 then self.angle = (math.pi/2-0.2) * signo(self.angle) end
	local new_pos = rotate_vector(
	self.startx,
	self.starty,
	rx, ry, self.angle )
	self.x = new_pos.x
	self.y = new_pos.y

	return do_shoot

end
