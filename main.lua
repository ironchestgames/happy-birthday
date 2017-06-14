love.graphics.setDefaultFilter('nearest', 'nearest')

local anim8 = require('anim8')

local SCREENWIDTH, SCREENHEIGHT

local TILESIZE = 16

local currentLevelIndex = 1

local avatar
local level
local lifts
local enemies

local A = 'A' -- avatar starting pos
local B = 'B' -- bricks
local C = 'C' -- concrete
local E = 'E' -- enemy, walking back and forth
local F = 'F' -- finish
local L = 'L' -- lava
local R = 'R' -- rusty bridge
local S = 'S' -- spikes
local H = 'H' -- horizontal lift
local V = 'V' -- vertical lift (upward)
local W = 'W' -- vertical lift (downward)

local levelData = {
  {C, 0, A, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, B, B, B, B, B, B, B, B, B, B, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, R, R, R, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, V, 0, W, 0, 0, 0, 0, B, B, 0, 0, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, B, B, B, B, 0, 0, 0, 0, 0, F, },
  {C, 0, 0, 0, R, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, 0, B, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, R, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, V, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, F, },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, L, L, L, L, L, L, L, L, C, C, C, C, C, C, C, C, C, C, C, 0, 0, 0, 0, 0, 0, C, L, L, L, L, C, 0, S, 0, 0, S, S, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, 0, C, 0, 0, C, C, S, S, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, },
}

local LEVELTILEHEIGHT = table.getn(levelData)
local LEVELTILEWIDTH = table.getn(levelData[1])

local LEVELVISIBLEOFFSETX = TILESIZE
local LEVELVISIBLEOFFSETY = TILESIZE * 2
local LEVELVISIBLEHEIGHT = (LEVELTILEHEIGHT - 3) * TILESIZE
local GRAPHICSSCALE

local BG_COLOR = {34, 32, 52, 255}

local avatarImage
local brickImage
local concreteImage
local liftImage
local spikesImage
local enemyImage

local avatarWalkingAnimation
local avatarJumpingAnimation
local avatarWalljumpAnimation
local avatarStandingAnimation

function isPointInsideRect(x, y, rx, ry, rw, rh)
  return (x >= rx and x <= rx + rw) and (y >= ry and y <= ry + rh)
end

function isRectOverlappingRect(x1, y1, w1, h1, x2, y2, w2, h2)
  return isPointInsideRect(x1, y1, x2, y2, w2, h2) or
    isPointInsideRect(x1 + w1, y1, x2, y2, w2, h2) or
    isPointInsideRect(x1, y1 + h1, x2, y2, w2, h2) or
    isPointInsideRect(x1 + w1, y1 + h1, x2, y2, w2, h2) or
    isPointInsideRect(x2, y2, x1, y1, w1, h1) or
    isPointInsideRect(x2 + w2, y2, x1, y1, w1, h1) or
    isPointInsideRect(x2, y2 + h2, x1, y1, w1, h1) or
    isPointInsideRect(x2 + w2, y2 + h2, x1, y1, w1, h1)
end

function resetGame()

  -- get desktop dimensions and graphics scale
  do
    local _, _, flags = love.window.getMode()
    SCREENWIDTH, SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)
    GRAPHICSSCALE = SCREENHEIGHT / LEVELVISIBLEHEIGHT

    love.window.setFullscreen(true)
  end

  -- reset avatar
  avatar = {

    -- flags
    isKeyJumpUsed = false,

    -- position etc
    x = 0,
    y = 0,
    w = TILESIZE - 1,
    h = TILESIZE - 1,
    velx = 0,
    vely = 0,
    accx = 0,
    accy = 0,
    direction = 1,

    -- gravity
    gravityAcc = 720,

    -- vel caps etc
    inAirMaxAcc = 1080,
    inAirMaxVelX = 120,
    inAirMaxVelY = 870,

    -- walking
    walkAcc = 1620,
    walkMaxVel = 108,

    -- jumping from ground
    jumpingEnabled = false,
    isOnGround = false,
    jumpVel = -300,

    -- wall jumping
    wallJumpingEnabled = false,
    isBesideWallRight = false,
    isBesideWallLeft = false,
    wallJumpVelY = -300,
    wallJumpVelX = 720,

    -- invincibility
    isInvincible = false,

    -- flying
    isFlying = false,
    flyingVelY = -168,

    -- crushing
    isCrushing = false,
  }

  -- select avatar powers
  if currentLevelIndex == 1 then
    avatar.isFlying = true
    avatar.isInvincible = true
    avatar.jumpingEnabled = true
    avatar.w = avatar.w * 2
    avatar.h = avatar.h * 2

  elseif currentLevelIndex == 2 then
    avatar.isInvincible = true
    avatar.wallJumpingEnabled = true
    avatar.jumpingEnabled = true

  elseif currentLevelIndex == 3 then
    avatar.isCrushing = true
    avatar.wallJumpingEnabled = true
    avatar.jumpingEnabled = true

  elseif currentLevelIndex == 4 then
    avatar.isCrushing = true
    avatar.jumpingEnabled = true

  elseif currentLevelIndex == 5 then
    avatar.jumpingEnabled = true

  elseif currentLevelIndex == 6 then
    -- nothing is enabled

  end

  -- load level and objects from level data
  level = {}
  lifts = {}
  enemies = {}

  for y, levelRowData in ipairs(levelData) do
    for x, tileData in ipairs(levelRowData) do

      if tileData == A then -- avatar start
        avatar.x = x * TILESIZE
        avatar.y = y * TILESIZE

      elseif tileData == B then -- bricks
        local tile = {
          t = B,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE,
          h = TILESIZE,
          crushed = false,
        }
        table.insert(level, tile)

      elseif tileData == C then -- concrete
        local tile = {
          t = C,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE,
          h = TILESIZE,
        }
        table.insert(level, tile)

      elseif tileData == E then -- enemy
        local enemy = {
          t = E,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE,
          h = TILESIZE,
          direction = -1,
          speed = 48,
          vely = 0,
          accy = 0,
          gravityAcc = 12,
          dead = false,
        }
        table.insert(enemies, enemy)

      elseif tileData == F then -- finish
        local tile = {
          t = F,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE,
          h = TILESIZE,
        }
        table.insert(level, tile)

      elseif tileData == L then -- lava
        local tile = {
          t = L,
          x = x * TILESIZE,
          y = y * TILESIZE + TILESIZE / 2,
          w = TILESIZE,
          h = TILESIZE / 2,
        }
        table.insert(level, tile)

      elseif tileData == R then -- rusty bridge
        local tile = {
          t = R,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE,
          h = TILESIZE,
          isBreaking = false,
          countdown = 0.7,
        }
        table.insert(level, tile)

      elseif tileData == S then -- spikes
        local tile = {
          t = S,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE,
          h = TILESIZE,
          cooldown = 0,
          cooldownTime = 2,
          isDeadly = false,
        }
        table.insert(level, tile)

      elseif tileData == V then -- vertical lift upward
        local lift = {
          t = V,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE * 2,
          h = TILESIZE / 2,
          speed = -60,
        }
        table.insert(lifts, lift)

      elseif tileData == W then -- vertical lift downward
        local lift = {
          t = W,
          x = x * TILESIZE,
          y = y * TILESIZE,
          w = TILESIZE * 2,
          h = TILESIZE / 2,
          speed = 60,
        }
        table.insert(lifts, lift)

      end
    end
  end
end

function love.keyreleased(key)
  if key == 'z' then
    avatar.isKeyJumpUsed = false
  end
end

function love.load()

  -- load images
  avatarImage = love.graphics.newImage('art/avatar_jumpingonly.png')
  brickImage = love.graphics.newImage('art/brick.png')
  concreteImage = love.graphics.newImage('art/concrete.png')
  liftImage = love.graphics.newImage('art/lift.png')
  spikesImage = love.graphics.newImage('art/spikes.png')
  enemyImage = love.graphics.newImage('art/enemy.png')

  -- init animations
  do
    local g = anim8.newGrid(16, 16, avatarImage:getWidth(), avatarImage:getHeight())
    avatarStandingAnimation = anim8.newAnimation(g(1, 1), 1)
    avatarJumpingAnimation = anim8.newAnimation(g(2, 1), 1)
    avatarWalljumpAnimation = anim8.newAnimation(g(3, 1), 1)
    avatarWalkingAnimation = anim8.newAnimation(g('4-6', 1), 0.1)
    
  end

  -- start game
  resetGame()
end

function love.update(dt)

  local isSidewaysInput = false
  local levelFinished = false
  local avatarDied = false

  -- move enemies
  for i, enemy in ipairs(enemies) do

    -- check if on ground
    local isOnGround = false
    for j, tile in ipairs(level) do
      if isPointInsideRect(
          enemy.x + enemy.w / 2,
          enemy.y + enemy.h + 1,
          tile.x,
          tile.y,
          tile.w,
          tile.h) then

        if tile.t == B or tile.t == C or tile.t == R then
          isOnGround = true
          enemy.y = tile.y - enemy.h
        elseif tile.t == L then
          enemy.dead = true
        end
        -- TODO: lifts?
        break
      end
    end

    -- if on ground, move back and forth on platform
    if isOnGround then
      local groundTestX = enemy.x + TILESIZE / 4
      local groundTestY = enemy.y + enemy.h + 1
      if enemy.direction == 1 then
        groundTestX = enemy.x + enemy.w - TILESIZE / 4
      end
      local changeDirection = true
      for j, tile in ipairs(level) do
        if isPointInsideRect(
            groundTestX,
            groundTestY,
            tile.x,
            tile.y,
            tile.w,
            tile.h) then
            changeDirection = false
          break
        end
        if isPointInsideRect(
            enemy.x - 1,
            enemy.y + enemy.h / 2,
            tile.x,
            tile.y,
            tile.w,
            tile.h) or
            isPointInsideRect(
            enemy.x + enemy.w + 1,
            enemy.y + enemy.h / 2,
            tile.x,
            tile.y,
            tile.w,
            tile.h) then
          break
        end
      end

      if changeDirection == true then
        enemy.direction = enemy.direction * -1
      end

      enemy.x = enemy.x + enemy.direction * enemy.speed * dt

    -- fall if not on ground
    else
      enemy.vely = enemy.vely + enemy.gravityAcc * dt
      enemy.y = enemy.y + enemy.vely

      -- die if outside level
      if enemy.y > LEVELTILEHEIGHT * TILESIZE then
        enemy.dead = true
      end
    end
  end

  -- check if avatar is on ground
  avatar.isOnGround = false
  for i, tile in ipairs(level) do
    if tile.t == B or tile.t == C or tile.t == R then
      if isRectOverlappingRect(
          avatar.x,
          avatar.y + avatar.h / 2,
          avatar.w,
          avatar.h * 0.75,
          tile.x,
          tile.y,
          tile.w,
          tile.h) then
        avatar.isOnGround = true
        if tile.t == R then
          tile.isBreaking = true
        end
        break
      end
    end
  end

  -- check if avatar is on lift
  for i, lift in ipairs(lifts) do
    if isRectOverlappingRect(
        lift.x,
        lift.y,
        lift.w,
        lift.h,
        avatar.x,
        avatar.y,
        avatar.w,
        avatar.h) then
      avatar.isOnGround = true
    end
  end

  -- check if avatar beside wall
  avatar.isBesideWallLeft = false
  avatar.isBesideWallRight = false

  if avatar.wallJumpingEnabled == true and
      avatar.isOnGround == false and
      avatar.isKeyJumpUsed == false then
    for i, tile in ipairs(level) do
      if tile.t == C or tile.t == B then
        if isRectOverlappingRect(
            tile.x - 2,
            tile.y,
            tile.w + 2,
            tile.h,
            avatar.x,
            avatar.y,
            avatar.w,
            avatar.h) then
          avatar.isBesideWallLeft = true
          break

        elseif isRectOverlappingRect(
            tile.x,
            tile.y,
            tile.w + 2,
            tile.h,
            avatar.x,
            avatar.y,
            avatar.w,
            avatar.h) then
          avatar.isBesideWallRight = true
          break
        end
      end
    end
  end

  -- check if avatar death by enemy
  for i, enemy in ipairs(enemies) do
    if isRectOverlappingRect(
        enemy.x,
        enemy.y,
        enemy.w,
        enemy.h,
        avatar.x,
        avatar.y,
        avatar.w,
        avatar.h) then
      if avatar.isInvincible == true then
        enemy.dead = true
      else
        avatarDied = true
      end
    end
  end

  -- consider jump input
  if love.keyboard.isDown('z') then

    -- flying
    if avatar.isOnGround == false and avatar.isFlying == true then
      if avatar.isKeyJumpUsed == false then
        avatar.vely = avatar.flyingVelY
        avatar.isKeyJumpUsed = true
      end
    else
      if avatar.isOnGround == true and avatar.jumpingEnabled == true then -- jump
        avatar.vely = avatar.jumpVel
        avatar.isOnGround = false
        avatar.isKeyJumpUsed = true

      elseif avatar.isBesideWallLeft == true and avatar.isKeyJumpUsed == false then -- wall jump left
        avatar.vely = avatar.wallJumpVelY
        avatar.velx = -avatar.wallJumpVelX
      elseif avatar.isBesideWallRight == true and avatar.isKeyJumpUsed == false then -- wall jump right
        avatar.vely = avatar.wallJumpVelY
        avatar.velx = avatar.wallJumpVelX
      end
    end
  end

  -- consider moving input
  if love.keyboard.isDown('right') then
    avatar.direction = 1
    if avatar.isOnGround == true then
      avatar.accx = avatar.walkAcc
    else
      avatar.accx = avatar.inAirMaxAcc
    end
    isSidewaysInput = true
  end

  if love.keyboard.isDown('left') then
    avatar.direction = -1
    if avatar.isOnGround == true then
      avatar.accx = -avatar.walkAcc
    else
      avatar.accx = -avatar.inAirMaxAcc
    end
    isSidewaysInput = true
  end

  -- avatar velx damping
  if avatar.isOnGround == true and isSidewaysInput == false then
    avatar.velx = avatar.velx * 0.7
  elseif avatar.isOnGround == false and isSidewaysInput == false then
    avatar.velx = avatar.velx * 0.96
  end

  -- apply avatar gravity
  avatar.accy = avatar.gravityAcc

  -- update avatar velocity
  avatar.velx = avatar.velx + avatar.accx * dt
  avatar.vely = avatar.vely + avatar.accy * dt

  -- cap sideways velocity
  if avatar.isOnGround == true then
    if avatar.velx > avatar.walkMaxVel then
      avatar.velx = avatar.walkMaxVel
    elseif avatar.velx < -avatar.walkMaxVel then
      avatar.velx = -avatar.walkMaxVel
    end
  else
    if avatar.velx > avatar.inAirMaxVelX then
      avatar.velx = avatar.inAirMaxVelX
    elseif avatar.velx < -avatar.inAirMaxVelX then
      avatar.velx = -avatar.inAirMaxVelX
    end
  end

  -- cap vertical velocity
  if avatar.vely > avatar.inAirMaxVelY then
    avatar.vely = avatar.inAirMaxVelY
  elseif avatar.vely < -avatar.inAirMaxVelY then
    avatar.vely = -avatar.inAirMaxVelY
  end

  -- update avatar postion and collide with level
  do
    local newX = avatar.x + avatar.velx * dt
    local newY = avatar.y + avatar.vely * dt
    for i, tile in ipairs(level) do

      if isRectOverlappingRect(
          newX,
          avatar.y,
          avatar.w,
          avatar.h,
          tile.x,
          tile.y,
          tile.w,
          tile.h) then

        if tile.t == B and avatar.isInvincible == true then
          tile.crushed = true
        elseif tile.t == B or tile.t == C then
          if avatar.x < tile.x then
            newX = tile.x - avatar.w - 0.01
          elseif avatar.x + tile.w > tile.x then
            newX = tile.x + tile.w + 0.01
          end
          newX = avatar.x
          avatar.velx = 0
        elseif tile.t == F then
          levelFinished = true
        end
      
      elseif isRectOverlappingRect(
          avatar.x,
          newY,
          avatar.w,
          avatar.h,
          tile.x,
          tile.y,
          tile.w,
          tile.h) then

        -- crush bricks
        if tile.t == B and
            avatar.isCrushing == true and
            avatar.y > tile.y then
          tile.crushed = true
        end

        -- invincible
        if tile.t == B and
            avatar.isInvincible == true and
            avatar.y > tile.y then
          tile.crushed = true

        -- stand on bricks and concrete
        elseif tile.t == B or tile.t == C then
          if avatar.y < tile.y then
            newY = tile.y - avatar.h - 0.01
          elseif avatar.y + tile.h > tile.y then
            newY = tile.y + tile.h + 0.01
          end
          avatar.vely = 0

        -- die on lava
        elseif tile.t == L then

          if avatar.isInvincible == false then
            avatarDied = true
          end

        -- stand and break rusty bridges
        elseif tile.t == R then

          if avatar.y < tile.y then
            newY = tile.y - avatar.h - 0.01
            avatar.vely = 0
            tile.isBreaking = true
          end

        end
      end
    end

    -- set new (collided and velocitied) position
    avatar.x = newX
    avatar.y = newY
  end

  -- test for spikes
  for i, tile in ipairs(level) do
    if tile.t == S and tile.isDeadly and isRectOverlappingRect(
        tile.x,
        tile.y,
        tile.w,
        tile.h,
        avatar.x,
        avatar.y,
        avatar.w,
        avatar.h) then
      if avatar.isInvincible == false then
        avatarDied = true
      end
    end
  end

  -- update lifts and avatar position
  for i, lift in ipairs(lifts) do
    lift.y = lift.y + lift.speed * dt
    if lift.y < 0 then
      lift.y = LEVELTILEHEIGHT * TILESIZE
    elseif lift.y > LEVELTILEHEIGHT * TILESIZE then
      lift.y = 0
    end
    if isRectOverlappingRect(
        lift.x,
        lift.y,
        lift.w,
        lift.h,
        avatar.x,
        avatar.y,
        avatar.w,
        avatar.h) then
      avatar.y = lift.y - avatar.h
      avatar.vely = lift.speed
    end
  end

  -- cap position within level
  if avatar.x < TILESIZE * 2 then
    avatar.x = TILESIZE * 2
  end
  if avatar.x > LEVELTILEWIDTH * TILESIZE then
    avatar.x = LEVELTILEWIDTH * TILESIZE
  end
  if avatar.y < TILESIZE * 0.25 then
    avatar.y = TILESIZE * 0.25
  end
  if avatar.y > LEVELTILEHEIGHT * TILESIZE then
    avatarDied = true
  end

  -- rusty bridges countdown
  for i = table.getn(level), 1, -1 do
    local tile = level[i]
    if tile.isBreaking == true then
      tile.countdown = tile.countdown - dt
      if tile.countdown <= 0 then
        table.remove(level, i)
      end
    end
  end

  -- spikes cooldown/update
  for i, tile in ipairs(level) do
    if tile.t == S then
      tile.cooldown = tile.cooldown + dt
      if tile.cooldown > tile.cooldownTime then
        tile.isDeadly = not tile.isDeadly
        tile.cooldown = 0
      end
    end
  end

  -- bricks crushed
  for i = table.getn(level), 1, -1 do
    local tile = level[i]
    if tile.crushed == true then
      table.remove(level, i)
    end
  end

  -- remove dead enemies
  for i = table.getn(enemies), 1, -1 do
    local enemy = enemies[i]
    if enemy.dead == true then
      table.remove(enemies, i)
    end
  end

  -- reset acceleration
  avatar.accy = 0
  avatar.accx = 0

  -- reset game if died
  if avatarDied == true then
    resetGame()
  end

  -- next level if finished
  if levelFinished == true then
    if currentLevelIndex == 6 then
      print('GAME OVER')
      love.event.quit()
    else
      currentLevelIndex = currentLevelIndex + 1
      resetGame()
    end
  end

  -- update animations
  avatarStandingAnimation:update(dt)
  avatarWalkingAnimation:update(dt)

end

function love.draw()

  -- set scale
  love.graphics.scale(GRAPHICSSCALE)

  love.graphics.push()

  -- follow avatar
  do
    local camerax = -(avatar.x - TILESIZE * 5)
    local cameray = TILESIZE * -2.75

    if camerax > -TILESIZE then
      camerax = -TILESIZE
    end
    love.graphics.translate(camerax, cameray)
  end

  -- draw bg
  do
    local levelW = table.getn(levelData[1]) * TILESIZE
    local levelH = (table.getn(levelData) - 3) * TILESIZE
    love.graphics.setColor(BG_COLOR)
    love.graphics.rectangle('fill', TILESIZE, TILESIZE * 2.75, levelW, levelH)
  end

  -- draw level
  for i, tile in ipairs(level) do
    if tile.t == B then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(brickImage, tile.x, tile.y)
    elseif tile.t == C then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(concreteImage, tile.x, tile.y)
    elseif tile.t == F then
      love.graphics.setColor(0, 255, 200)
      love.graphics.rectangle('fill', tile.x, tile.y, tile.w, tile.h)
    elseif tile.t == L then
      love.graphics.setColor(255, love.math.random(0, 140), 0)
      love.graphics.rectangle('fill', tile.x, tile.y, tile.w, tile.h)
    elseif tile.t == R then
      if tile.isBreaking == false then
        love.graphics.setColor(90, 60, 30)
      else
        love.graphics.setColor(90, 60, 30, 200)
      end
      love.graphics.rectangle('fill', tile.x, tile.y, tile.w, tile.h)
    end
  end

  -- draw enemies
  for i, enemy in ipairs(enemies) do
    if enemy.t == E then
      love.graphics.setColor(255, 255, 255, 255)
      local directionOffsetX = 0
      if enemy.direction == -1 then
        directionOffsetX = enemy.w
      end
      love.graphics.draw(enemyImage, enemy.x + directionOffsetX, enemy.y, 0, enemy.direction, 1)
    end
  end

  -- draw lifts
  love.graphics.setColor(255, 255, 255, 255)
  for i, lift in ipairs(lifts) do
    if lift.t == V or lift.t == W then
      love.graphics.draw(liftImage, lift.x, lift.y)
    end
  end

  -- draw avatar
  do
    love.graphics.setColor(255, 255, 255, 255)
    local x = avatar.x
    if avatar.direction == -1 then
      x = avatar.x + avatar.w
    end
    if avatar.isBesideWallLeft == true then
      avatarWalljumpAnimation:draw(avatarImage, avatar.x, avatar.y, 0, 1, 1)
    elseif avatar.isBesideWallRight == true then
      avatarWalljumpAnimation:draw(avatarImage, avatar.x + avatar.w, avatar.y, 0, -1, 1)
    elseif avatar.isOnGround == false then
      avatarJumpingAnimation:draw(avatarImage, x, avatar.y, 0, avatar.direction, 1)
    elseif math.abs(avatar.velx) < 1 then
      avatarStandingAnimation:draw(avatarImage, x, avatar.y, 0, avatar.direction, 1)
    else
      avatarWalkingAnimation:draw(avatarImage, x, avatar.y, 0, avatar.direction, 1)
    end
  end

  -- draw spikes
  love.graphics.setColor(255, 255, 255, 255)
  for i, tile in ipairs(level) do
    if tile.t == S and tile.isDeadly then
      love.graphics.draw(spikesImage, tile.x, tile.y)
    end
  end

  -- debug draw
  -- love.graphics.setColor(255, 255, 0, 120)
  -- love.graphics.rectangle('fill',
  --     avatar.x,
  --     avatar.y + avatar.h / 2,
  --     avatar.w,
  --     avatar.h * 0.75)

  love.graphics.pop()

end
