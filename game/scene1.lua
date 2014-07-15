

scene1 = {}


function player_shot()
	if not ray_active then
		sfx_shoot:rewind()
		sfx_shoot:play()
		local bullet = Bullet:new( huevos.x, huevos.y, hero.angle )
		table.insert( bullets, bullet )
	end
end

function scene1:enter()

	global_timer = 0
	shader_shake_current = 0
	shader_time = 0
	shake_current = 0
	ray_active = false
	shield_active = false
	shield_power = 1
	enemies = {}
	bullets = {}
	explosions = {}
	enemy_rush = 0
	scene_state = "prelude"
	hero = Hero:new()
	enemy_timer = 0
	level_timer = 0
	current_level = 0
	eclosion_timer = 0
	huevos = Huevos:new()
	eclosionado = false
	player_active = true

end

function killAll()
	huevos:eclosionar()
	for k in pairs (enemies) do
		spawnExplosion(enemies[k].x, enemies[k].y)
		enemies [k] = nil
	end
	for k in pairs (bullets) do
		bullets [k] = nil
	end
	player_active = false
	spawnExplosion(hero.x, hero.y)
end

function spawnExplosion(x,y)
	table.insert( explosions, Explosion:new( x-40, y-40 ) )
end

function scene1:update(dt)

	--[[
		level_timer = level_timer - dt
	if current_level < LEVEL_LIMIT and level_timer <= 0 then
		ENEMY_SPAWN_TIMER.val = ENEMY_SPAWN_TIMER.val / 2
		current_level = current_level + 1
		level_timer = NEXT_LEVEL_TIMER
	end
	--]]
	--

	Timer.update(dt)

	global_timer = global_timer + dt
	-- 21
	if global_timer > 8 and current_level == 0 then
		ENEMY_SPAWN_TIMER.val = 0.5
		current_level = 1
	elseif global_timer > 22 and current_level == 1 then
		ENEMY_SPAWN_TIMER.val = 0.045
		current_level = 2
		Timer.tween( 40, ENEMY_SPAWN_TIMER, { val = 0.015} , 'linear' )
	elseif current_level == 2 then
		--[[
		local time = global_timer - 22
		if time < 10 then ENEMY_SPAWN_TIMER.val = 0.045
		elseif time < 20 then ENEMY_SPAWN_TIMER.val = 0.035
		elseif time < 30 then ENEMY_SPAWN_TIMER.val = 0.025
		elseif time < 40 then ENEMY_SPAWN_TIMER.val = 0.015
		end
		--]]
	end

	if scene_state == "prelude" and huevos:remainingEggs() == 1 then
		eclosion_timer = eclosion_timer + dt
		if shield_power <= 0 then --eclosion_timer > 6 then
			shield_power = 0
			scene_state = "eclosion" -- start egg explosion sequence
			sfx_ray:stop()
			eclosion_timer = 0
		end
	end

	if scene_state == "prelude" then

		-- hero update
		if hero:update(dt, huevos.x, huevos.y) then
			-- shake increase
			--print("INC!")
			if not ray_active then
				shake_current = shake_current + 1 * signo( shake_current ) * SHAKE_ATTACK
			end
			if math.abs( shake_current ) > 1000 then shake_current = 1000 * signo( shake_current ) end
		else
			-- shake decrease
			--print("DEC!")
			if not ray_active then
				shake_current = shake_current * SHAKE_DECAY
			end
		end

		if not ray_active then
			sfx_ray:stop()
			if enemy_rush >= RAY_FULL and love.keyboard.isDown("up") then
				ray_active = true
			end
		else
			sfx_ray:play()
			shake_current = shake_current + 1 * signo(shake_current ) * (SHAKE_ATTACK_RAY)
			enemy_rush = enemy_rush - 1
			if enemy_rush == 0 then
				ray_active = false
			end
		end



		-- huevos update
		huevos:update(dt)

		-- update enemy spawn
		enemy_timer = enemy_timer - dt
		if enemy_timer <= 0 then
			table.insert( enemies, Enemy:new( huevos.x, huevos.y, 30, 150 ) )
			enemy_timer = ENEMY_SPAWN_TIMER.val
		end

		-- enemy/bullet/explosion clearing
		local delete_bullets = {}
		local delete_enemies = {}

		-- enemy update
		shield_active = ray_active or huevos:remainingEggs() == 1
		for k, enemy in pairs(enemies) do
			-- si no tiene el huevo y esta en el area de los huevos
			if not enemy.hasEgg and  distance_point_point( enemy.x, enemy.y, huevos.x+20, huevos.y+60 ) < 100 then
				-- si los escudos NO estan activos
				if not shield_active then
					-- toma el huevo
					print("HEY!!" .. huevos:remainingEggs())
					enemy.hasEgg = true
					huevos:dropEgg()
				-- si los escudos SI estan activos
				else
					-- quitamos salud al escudo SOLO si estamos en el scene_state "eclosion"
					if huevos:remainingEggs() == 1 and not enemy.hasEgg then
						table.insert( delete_enemies, k )
						table.insert( explosions, Explosion:new( enemy.x-40, enemy.y-40 ) )
						enemy.active = false
						shield_power = shield_power - 0.1
					end
				end

			end
			if enemy:update(dt) then
				table.insert( delete_enemies, k )
			else
				--if collision_aabb( enemy.x, enemy.y
				-- check col with huevos
			end
		end


		-- bullet update
		for k,bullet in pairs(bullets) do
			if bullet:update(dt) then
				table.insert( delete_bullets, k )
			end
		end

		-- bullet vs enemy collision check
		pun = rotate_vector( 400, 400, huevos.x, huevos.y, hero.angle )
		--	pun = rotate_vector( huevos.x, huevos.y, huevos.x, huevos.y-400, -hero.angle )
		for ke,e in pairs(enemies) do
			local d1 = distance_point_line( huevos.x,huevos.y,pun.x,pun.y,e.x,e.y)
			local d2 = distance_point_line( huevos.x+10,huevos.y+10,pun.x,pun.y,e.x,e.y)
			if ray_active then
				if d1 < 20 then--collision_point_obb( hero.x, hero.y, rayanim:getWidth(), rayanim:getHeight(), e.x, e.y, -hero.angle ) then
					if not ray_active and enemy_rush < RAY_FULL then enemy_rush = enemy_rush + 1 end
					sfx_explo:rewind()
					sfx_explo:play()
					table.insert( explosions, Explosion:new( e.x-40, e.y-40 ) )
					table.insert( delete_enemies, ke )
				end
			end
			for kb,b in pairs(bullets) do
				if e:checkCol(b) then
					if not ray_active and enemy_rush < RAY_FULL then enemy_rush = enemy_rush + 1 end
					sfx_explo:rewind()
					sfx_explo:play()
					table.insert( explosions, Explosion:new( e.x-40, e.y-40 ) )
					table.insert( delete_enemies, ke )
					table.insert( delete_bullets, kb )
				end
			end
		end

		-- bullet clearing
		for k,v in pairs(delete_bullets) do
			table.remove( bullets, v )
		end

		-- enemy clearing
		for k,v in pairs(delete_enemies) do
			table.remove( enemies, v )
		end


		upray_anim:update(dt)
	elseif scene_state == "eclosion" then

		if eclosion_timer == 0 then
			-- primera vez
			Timer.tween( 4.5, huevos, { scale = 10, xoffset = -200, yoffset = -500 }, 'linear' )
			bgm:stop()
			sfx_exploinit:play()
			Timer.add( 4.5, function()
				killAll()
				huevos.xoffset = -50
				eclosionado = true
				Timer.tween( 5, huevos, {scale = 5, xoffset = -50, yoffset = -300 }, 'out-elastic' )
			end )
		end

		if eclosionado == false then shake_current = eclosion_timer * 5
		else  shake_current = shake_current * 0.99
		end
		eclosion_timer = eclosion_timer + dt
		--shake_current = eclosion_timer * 5
		--if eclosion_timer > 4.5 then killAll() end
		--[[
		if eclosion_timer < 6 then
			huevos:setOffset( -eclosion_timer * 10, -eclosion_timer * 100 )
			huevos:setScale(1+eclosion_timer)
		end
		--]]
		huevos:update(dt)
		--shake_current = shake_current * 0.9
	end

	local delete_explosions = {}

	-- explosions
	for k,e in pairs(explosions) do
		if e:update(dt) then
			table.insert( delete_explosions, k )
		end
	end

	-- explosion clearing
	for k,v in pairs(delete_explosions) do
		table.remove( explosions, v )
	end

	-- camera shake
	camera:setPosition( 0, 0 )
	local cam_random_shake_x = love.math.randomNormal()
	local cam_random_shake_y = love.math.randomNormal()
	if love.math.randomNormal() > 0.5 then camera:move( shake_current, shake_current )
	else camera:move( shake_current * cam_random_shake_y, -shake_current * cam_random_shake_x ) end
	shake_current = shake_current * (-1)

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
	shader_bg:send( "time", 		shader_time )
	shader_bg:send( "factor",	shader_shake_current )
	shader_bg:send( "angle", 	shader_pixel_rotation )

end

function scene1:draw()
	--love.graphics.print("asd ola q ase", 300, 300)
	camera:set()

	-- draw bg
	love.graphics.setShader(shader_bg)
	love.graphics.rectangle("fill",-100,-100,width+200,height+200)
	love.graphics.setShader()


	-- draw enemies
	for k,enemy in pairs(enemies) do
		enemy:draw()
	end

	if player_active then 
		if ray_active then
			rayanim:draw( hero.x, hero.y, hero.angle, 1, 1, rayanim:getWidth()-13, rayanim:getHeight() )
		end
	end

	-- draw huevos
	huevos:draw()

	if shield_power < 0 then shield_power = 0 end
	if shield_active then
		love.graphics.setColor( 255, 255, 255, shield_power * 255 )
		protect:draw( huevos.x-45, huevos.y-30 )
		love.graphics.setColor( 255, 255, 255, 255 )
	end

	-- draw bullets
	for k,bullet in pairs(bullets) do
		bullet:draw()
	end

	-- draw explosions
	for k,e in pairs(explosions) do
		e:draw()
	end

	if scene_state == "prelude" then
		if not ray_active and enemy_rush == RAY_FULL then
			upray_anim:draw(100,100)
		end
	end


	if player_active then
		hero.anim:draw( hero.x, hero.y, hero.angle, 1, 1, hero.anim:getWidth()/2, hero.anim:getHeight()/2 )
	end

	camera:unset()

	for i=1,enemy_rush do
		bar:draw( 100 + i , 540 )
	end


--[[
	love.graphics.point(huevos.x,huevos.y)
	local i = 0
	while i < 2*math.pi do
		local puntotest = rotate_vector( huevos.x, huevos.y-400, huevos.x, huevos.y, i )
		love.graphics.point(puntotest.x,puntotest.y)

		love.graphics.print( math.deg(i), puntotest.x, puntotest.y )

		i = i + math.pi/4
	end
	--]]
	--love.graphics.print( "entidades" .. (#enemies + #bullets), 100, 100 )
end
