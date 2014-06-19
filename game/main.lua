
require "camera"
require "shaderlib"
require "AnAL"

local width = 800
local height = 600


function love.conf(t)
	t.window.width = width
	t.window.height = height
end

function dot_product( x1, y1, x2, y2 )
	return x1 * x2 + y1 * y2
end

function love.load()

	shader_bg = love.graphics.newShader( shadercombo )
	shader_shake_current = 0
	shader_time = 0
	shake_current = 0
	last_shot = 0
	camera:setBounds( 0, 0, width, height )

	enemies = {}
	bullets = {}

	hero = {}
	hero.startx = 390
	hero.starty = 400
	hero.x = hero.startx
	hero.y = hero.starty
	hero.speed = 200
	hero.angle = 0

	spawned = 0

	hero_anim = newAnimation( love.graphics.newImage("ranamadre.png"), 60, 42, 0.1, -1 )
	hero_anim:addFrame(0, 0, 60, 42, 1)
	hero_anim:addFrame(60, 0, 60, 42, 0.1)
	hero_anim:addFrame(0, 0, 60, 42, 0.1)
	hero_anim:addFrame(60, 0, 60, 42, 0.1)
	hero_anim:addFrame(0, 0, 60, 42, 0.8)
	hero_anim:addFrame(60, 0, 60, 42, 0.1)
	hero_anim:addFrame(0, 0, 60, 42, 1)
	hero_anim:addFrame(60, 0, 60, 42, 0.1)
	hero_anim:setMode("bounce")

	huevos = {}
	huevos_x_offset = 390
	huevos_y_offset = 480

	for i=0,1 do
		for j=i,2 do
			local animat = newAnimation( love.graphics.newImage("huevo.png"), 42, 42, 0.1, -1 )
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
			local huevo = { x = - 64 + huevos_x_offset + j * xoff + (1-i) * 15, y = huevos_y_offset - i * yoff, anim = animat }
			huevo.anim:update( math.random(0,10) )
			table.insert( huevos, huevo )
		end
	end
end



function rotate_over( px, py, cx, cy, angle )
	local s, c, xnew, ynew, ppx, ppy
	s = math.sin(angle)
	c = math.cos(angle)
	ppx = px - cx;
	ppy = py - cy;
	xnew =  ppx * c + ppy * s
	ynew = -ppx * s + ppy * c
	return { x = xnew + cx, y = ynew + cy }
end

function signo(num)
	if num >= 0 then return 1 end
	return -1
end

function normalize(vx, vy)
	local mod = vecmod(vx,vy)
	return  { x = vx / mod, y = vy / mod }
end

function vecmod(vx, vy)
	return math.sqrt((vx * vx) + (vy * vy))
end


function love.update(dt)

	spawned = spawned - dt
	if spawned <= 0 then
		spawn_enemy(5)
		spawned = 0.2
	end
	print(shader_time)

	-- cam animation
	shader_time = shader_time + dt * 10
	local camera_scale = math.abs( 0.008 * math.sin( shader_time / 10 ) ) + 0.9
	camera:setScale( camera_scale, camera_scale )
	camera:setRotation( 0.05 * math.sin( shader_time / 10 ) )

	-- divisor de intensidad para la epilepsia
	local shader_shake_intensity = 20
	local shader_shake_current = math.abs( shake_current / shader_shake_intensity )
	if shader_shake_current > 1 then shader_shake_current = 1 end

	-- rotacion para la psicodelia
	local shader_pixel_rotation = -0.1*math.sin(5+shader_time/10)

	-- shader uniforms
	shader_bg:send("time", shader_time)
	shader_bg:send("factor", shader_shake_current )
	shader_bg:send("angle", shader_pixel_rotation)

	-- huevos update
	for k,huevo in pairs(huevos) do
		huevo.anim:update(dt)
	end


	local deleteb = {}
	local deletee = {}

	-- enemigos update
	for k, enemy in pairs(enemies) do
		enemy.x = (enemy.x - enemy.dir.x * enemy.speed)
		enemy.y = (enemy.y - enemy.dir.y * enemy.speed)
		enemy.anim:update(dt, enemy.angle,1,1,0,0)
		if not CheckCollision( enemy.x, enemy.y, enemy.anim:getWidth(), enemy.anim:getHeight(), 0, 0, 800, 600 ) then
			table.insert( deletee, k )
		end
	end


	for k,bullet in pairs(bullets) do
		bullet.x = bullet.x + bullet.dir.x * bullet.speed
		bullet.y = bullet.y + bullet.dir.y * bullet.speed
		bullet.anim:update(dt, bullet.angle, 1, 1, 0, 0)
		if not CheckCollision( bullet.x, bullet.y, bullet.anim:getWidth(), bullet.anim:getHeight(), 0, 0, 800, 600 ) then
			table.insert( deleteb, k )
		end
	end

	for ke,e in pairs(enemies) do
		for kb,b in pairs(bullets) do
			if CheckCollision( e.x, e.y, e.anim:getWidth(), e.anim:getWidth(), b.x, b.y, b.anim:getWidth(), b.anim:getWidth() ) then
				table.insert( deletee, ke )
				table.insert( deleteb, kb )
			end
		end
	end

	for k,v in pairs(deleteb) do
		table.remove( bullets, v )
	end

	for k,v in pairs(deletee) do
		table.remove( enemies, v )
	end


	-- hero keyboard update
	local step = 0.1
	if love.keyboard.isDown("left") then hero.angle = hero.angle + step
	elseif love.keyboard.isDown("right") then hero.angle = hero.angle - step end

	local do_shoot = false
	if love.keyboard.isDown(" ") or love.keyboard.isDown("up") then
		do_shoot = true
		shake_current = shake_current + 1 * signo( shake_current ) * 0.05
		if math.abs( shake_current ) > 1000 then shake_current = 1000 * signo( shake_current ) end
	else shake_current= shake_current * 0.9 end

	last_shot = last_shot - dt
	if do_shoot and last_shot <= 0 then
		player_shot()
		last_shot = 0.03
	end

	-- hero rotation update
	hero_anim:update(dt)
	if math.abs(hero.angle) > math.pi/2 then hero.angle = math.pi/2 * signo(hero.angle) end
	local hero_new_pos = rotate_over(
		hero.startx,
		hero.starty,
		huevos_x_offset, huevos_y_offset, hero.angle )
	hero.x = hero_new_pos.x
	hero.y = hero_new_pos.y

	-- camera shake
	camera:setPosition( 0, 0 )
	local cam_random_shake_x = love.math.randomNormal()
	local cam_random_shake_y = love.math.randomNormal()
	if love.math.randomNormal() > 0.5 then camera:move( shake_current, shake_current )
	else camera:move( shake_current * cam_random_shake_y, -shake_current * cam_random_shake_x ) end
	shake_current = shake_current * (-1)


end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function spawn_enemy( sped )
	local animat = newAnimation( love.graphics.newImage("bicho.png"), 56, 78, 0, -1 )
	animat:addFrame(42,0,42,78,0.1)		-- aleta izq
	animat:addFrame(84,0,42,78,0.1)		-- mordisco
	animat:addFrame(126,0,42,78,0.1)	-- aleta der
	animat:addFrame(84,0,42,78,0.1)		-- mordisco
	animat:setMode("bounce")

	                                  -- tres decimales, sobrado
	local rand = love.math.random( 0, 1000 * math.pi ) / 1000 - math.pi/2
	local pos = rotate_over( 400 - animat:getWidth()/2, 0, huevos_x_offset, huevos_y_offset, rand )
	local enemy_dir = normalize( pos.x - huevos_x_offset, pos.y - huevos_y_offset )


	local enemy = { active = true, x = pos.x, y = pos.y, speed = sped, anim = animat, angle = -rand, dir = { x = enemy_dir.x, y = enemy_dir.y } }
	print("grados rand", rand)
	table.insert( enemies, enemy )
end

function player_shot()
	local animat = newAnimation( love.graphics.newImage("tiro0.png"), 13, 30, 0, 0 )
	local pos = rotate_over( 400 - animat:getWidth()/2, 400, huevos_x_offset, huevos_y_offset, hero.angle )
	local bullet_dir = normalize( pos.x - huevos_x_offset, pos.y - huevos_y_offset )
	local bullet = { active = true, x = pos.x , y = pos.y , speed = 15, anim = animat, angle = hero.angle, dir = { x = bullet_dir.x, y = bullet_dir.y }  }
	table.insert( bullets, bullet )

	--[[
	local rand = math.pi*2 - love.math.random( 8000, 40000 ) / 10000
	local pos = rotate_over( 0, 800, huevos_x_offset - 60, huevos_y_offset - 60, rand )
	local animat = newAnimation( love.graphics.newImage("bicho.png"), 56, 78, 0, -1 )
	local enemy_new_pos = normalize( pos.x - huevos_x_offset, pos.y - huevos_y_offset )

	animat:addFrame(42,0,42,78,0.1)		-- aleta izq
	animat:addFrame(84,0,42,78,0.1)		-- mordisco
	animat:addFrame(126,0,42,78,0.1)	-- aleta der
	animat:addFrame(84,0,42,78,0.1)		-- mordisco
	animat:setMode("bounce")

	local enemy = { x = pos.x, y = pos.y, speed = sped, anim = animat, angle = 5*math.pi/4-rand, dir = { x = enemy_new_pos.x, y = enemy_new_pos.y } }
	table.insert( enemies, enemy )
	--]]

end

function love.draw()

	camera:set()

	-- draw bg
	love.graphics.setShader(shader_bg)
	love.graphics.rectangle("fill",-100,-100,width+200,height+200)
	love.graphics.setShader()

	-- draw huevos
	for k,huevo in pairs(huevos) do
		huevo.anim:draw(huevo.x, huevo.y)
	end

	for k,enemy in pairs(enemies) do
		enemy.anim:draw(enemy.x, enemy.y, enemy.angle, 1, 1, enemy.anim:getWidth()/2, enemy.anim:getHeight()/2)
	end


	for k,bullet in pairs(bullets) do
		bullet.anim:draw(bullet.x, bullet.y, -bullet.angle, 1, 1, bullet.anim:getWidth()/2, bullet.anim:getHeight()/2)
	end

	hero_anim:draw( hero.x, hero.y, -hero.angle, 1, 1, hero_anim:getWidth()/2, hero_anim:getHeight()/2 )

	camera:unset()

end
