love.graphics.setDefaultFilter('nearest', 'nearest')

local anim8 = require('anim8')

local SCREENWIDTH, SCREENHEIGHT

local TILESIZE = 16

local currentLevelIndex = 1

local respawnTime = 3
local respawnCount = 0
local isRespawning = false

local avatar
local level
local lifts
local enemies

local deadEnemies

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
  {C, 0, A, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, B, B, B, B, B, B, B, B, B, B, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, R, R, R, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, V, 0, 0, 0, 0, 0, 0, B, B, 0, 0, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, R, 0, 0, 0, 0, B, B, B, B, B, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, B, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, R, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, E, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, V, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, B, B, 0, E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, F, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, L, L, L, L, L, L, L, L, C, C, C, C, C, C, C, C, C, C, C, 0, 0, 0, 0, 0, 0, C, L, L, L, L, C, 0, S, 0, 0, S, S, 0, 0, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, 0, C, 0, 0, C, C, S, S, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, 0, 0, 0, B, B, B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C, C },
}

local LEVELTILEHEIGHT = table.getn(levelData)
local LEVELTILEWIDTH = table.getn(levelData[1])

local LEVELVISIBLEOFFSETX = TILESIZE
local LEVELVISIBLEOFFSETY = TILESIZE * 2
local LEVELVISIBLEHEIGHT = (LEVELTILEHEIGHT - 3) * TILESIZE
local GRAPHICSSCALE

local BG_COLOR = {34, 32, 52, 255}

local avatarImage
local avatarInvincibleImage
local avatarCaneImage
local avatarWingsImage
local brickImage
local concreteImage
local liftImage
local spikesImage
local enemyImage
local rustyBridgeImage
local lavaImage
local finishImage

local avatarWalkingAnimation
local avatarJumpingAnimation
local avatarCrushingAnimation
local avatarWalljumpAnimation
local avatarStandingAnimation
local avatarFlyingAnimation

local avatarWingsStillAnimation
local avatarWingsFlappingAnimation

local rustyBridgeIdleAnimation
local rustyBridgeBreakingAnimation

local lavaAnimation

local enemyAnimation

local finishAnimation

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
    isCrying = false,

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
    invincibleEnabled = false,

    -- flying
    flyingEnabled = false,
    flyingVelY = -168,

    -- crushing
    crushingEnabled = false,
  }

  -- select avatar powers
  if currentLevelIndex == 1 then
    avatar.flyingEnabled = true
    avatar.invincibleEnabled = true
    avatar.jumpingEnabled = true
    avatar.w = avatar.w * 2
    avatar.h = avatar.h * 2

  elseif currentLevelIndex == 2 then
    avatar.invincibleEnabled = true
    avatar.wallJumpingEnabled = true
    avatar.jumpingEnabled = true

  elseif currentLevelIndex == 3 then
    avatar.crushingEnabled = true
    avatar.wallJumpingEnabled = true
    avatar.jumpingEnabled = true

  elseif currentLevelIndex == 4 then
    avatar.crushingEnabled = true
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
  deadEnemies = {}

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
  avatarImage = love.graphics.newImage('art/avatar.png')
  avatarInvincibleImage = love.graphics.newImage('art/avatar_invincible.png') -- NOTE: must be same size as avatarImage
  avatarCaneImage = love.graphics.newImage('art/avatar_cane.png') -- NOTE: must be same size as avatarImage
  avatarWingsImage = love.graphics.newImage('art/avatar_wings.png')
  brickImage = love.graphics.newImage('art/brick.png')
  concreteImage = love.graphics.newImage('art/concrete.png')
  liftImage = love.graphics.newImage('art/lift.png')
  spikesImage = love.graphics.newImage('art/spikes.png')
  enemyImage = love.graphics.newImage('art/enemy.png')
  enemyDeadImage = love.graphics.newImage('art/enemy_dead.png')
  rustyBridgeImage = love.graphics.newImage('art/rustybridge.png')
  lavaImage = love.graphics.newImage('art/lava.png')
  finishImage = love.graphics.newImage('art/finish.png')

  -- init animations
  do
    local g

    g = anim8.newGrid(16, 16, avatarImage:getWidth(), avatarImage:getHeight())
    avatarStandingAnimation = anim8.newAnimation(g(1, 1), 1)
    avatarCrushingAnimation = anim8.newAnimation(g(2, 1), 1)
    avatarWalljumpAnimation = anim8.newAnimation(g(3, 1), 1)
    avatarWalkingAnimation = anim8.newAnimation(g('4-6', 1), 0.1)
    avatarFlyingAnimation = anim8.newAnimation(g(7, 1), 1)
    avatarJumpingAnimation = anim8.newAnimation(g(8, 1), 1)
    avatarCryingAnimation = anim8.newAnimation(g('9-11', 1), 0.3)

    g = anim8.newGrid(32, 16, avatarWingsImage:getWidth(), avatarWingsImage:getHeight())
    avatarWingsStillAnimation = anim8.newAnimation(g(1, 1), 1)
    avatarWingsFlappingAnimation = anim8.newAnimation(g('2-4', 1), 0.14, 'pauseAtEnd')

    g = anim8.newGrid(16, 16, rustyBridgeImage:getWidth(), rustyBridgeImage:getHeight())
    rustyBridgeIdleAnimation = anim8.newAnimation(g(1, 1), 1)
    rustyBridgeBreakingAnimation = anim8.newAnimation(g('2-3', 1), 0.007)

    g = anim8.newGrid(16, 16, lavaImage:getWidth(), lavaImage:getHeight())
    lavaAnimation = anim8.newAnimation(g('1-4', 1), 0.1)

    g = anim8.newGrid(16, 16, enemyImage:getWidth(), enemyImage:getHeight())
    enemyAnimation = anim8.newAnimation(g('1-2', 1), 0.15)

    g = anim8.newGrid(16, 16, finishImage:getWidth(), finishImage:getHeight())
    finishAnimation = anim8.newAnimation(g('1-2', 1), 0.15)

  end

  -- start game
  resetGame()
end

function love.update(dt)

  -- update animations
  avatarStandingAnimation:update(dt)
  avatarWalkingAnimation:update(dt)
  avatarCryingAnimation:update(dt)
  avatarWingsFlappingAnimation:update(dt)
  rustyBridgeBreakingAnimation:update(dt)
  lavaAnimation:update(dt)
  enemyAnimation:update(dt)
  finishAnimation:update(dt)

  -- do special things if respawning
  if isRespawning == true then
    respawnCount = respawnCount - dt
    if respawnCount < 0 then
      isRespawning = false
      resetGame()
    end
    return
  end

  -- set up local vars
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
      if avatar.invincibleEnabled == true then
        enemy.dead = true
      else
        avatarDied = true
      end
    end
  end

  -- consider jump input
  if love.keyboard.isDown('z') then

    -- flying
    if avatar.isOnGround == false and avatar.flyingEnabled == true then
      if avatar.isKeyJumpUsed == false then
        avatar.vely = avatar.flyingVelY
        avatar.isKeyJumpUsed = true

        -- flapping animation
        avatarWingsFlappingAnimation:gotoFrame(2)
        avatarWingsFlappingAnimation:resume()
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

        if tile.t == B and avatar.invincibleEnabled == true then
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
            avatar.crushingEnabled == true and
            avatar.y > tile.y then
          tile.crushed = true
        end

        -- invincible
        if tile.t == B and
            avatar.invincibleEnabled == true and
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

          if avatar.invincibleEnabled == false then
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
      if avatar.invincibleEnabled == false then
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

      -- add dead enemy
      local deadEnemy = {
        x = enemy.x,
        y = enemy.y,
        velx = enemy.direction * 150,
        vely = -150,
        gravityAcc = 12,
      }
      table.insert(deadEnemies, deadEnemy)
    end
  end

  -- move dead enemies
  for i = table.getn(deadEnemies), 1, -1 do
    local deadEnemy = deadEnemies[i]
    deadEnemy.vely = deadEnemy.vely + deadEnemy.gravityAcc
    deadEnemy.velx = deadEnemy.velx * 0.9
    deadEnemy.x = deadEnemy.x + deadEnemy.velx * dt
    deadEnemy.y = deadEnemy.y + deadEnemy.vely * dt

    if deadEnemy.y > LEVELTILEHEIGHT * TILESIZE then
      table.remove(deadEnemies, i)
    end
  end

  -- reset acceleration
  avatar.accy = 0
  avatar.accx = 0

  -- reset game if died
  if avatarDied == true then
    avatar.isCrying = true
    isRespawning = true
  end

  -- next level if finished
  if levelFinished == true then
    if currentLevelIndex == 6 then
      print('YOU MADE IT!')
      love.event.quit()
    else
      currentLevelIndex = currentLevelIndex + 1
      isRespawning = true
    end
  end

  -- set-up respawning
  if isRespawning == true then
    respawnCount = respawnTime
  end

end

function love.draw()

  -- calc fading color
  local fadingColor
  if isRespawning == true then
    local c = (respawnCount / respawnTime) * 255
    fadingColor = {c, c, c}
  else
    fadingColor = {255, 255, 255}
  end

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
  love.graphics.setColor(fadingColor)
  for i, tile in ipairs(level) do
    if tile.t == B then
      love.graphics.draw(brickImage, tile.x, tile.y)
    elseif tile.t == C then
      love.graphics.draw(concreteImage, tile.x, tile.y)
    elseif tile.t == F then
      love.graphics.setColor(255, 255, 255, 255)
      finishAnimation:draw(finishImage, tile.x, tile.y)
      love.graphics.setColor(fadingColor)
    elseif tile.t == R then
      if tile.isBreaking == false then
        rustyBridgeIdleAnimation:draw(rustyBridgeImage, tile.x, tile.y)
      else
        rustyBridgeBreakingAnimation:draw(rustyBridgeImage, tile.x, tile.y)
      end
    end
  end

  -- draw enemies
  for i, enemy in ipairs(enemies) do
    if enemy.t == E then
      local directionOffsetX = 0
      if enemy.direction == -1 then
        directionOffsetX = enemy.w
      end
      enemyAnimation:draw(enemyImage, enemy.x + directionOffsetX, enemy.y, 0, enemy.direction, 1)
    end
  end

  -- draw lifts
  for i, lift in ipairs(lifts) do
    if lift.t == V or lift.t == W then
      love.graphics.draw(liftImage, lift.x, lift.y)
    end
  end

  -- draw avatar
  do
    love.graphics.setColor(255, 255, 255)
    local image = avatarImage
    if avatar.invincibleEnabled == true then
      image = avatarInvincibleImage
    elseif avatar.jumpingEnabled == false then
      image = avatarCaneImage
    end

    local x = avatar.x
    if avatar.direction == -1 then
      x = avatar.x + avatar.w
    end

    local y = avatar.y

    local scaleFactor = avatar.w / TILESIZE

    -- draw wings
    if avatar.flyingEnabled == true then
      if avatar.isOnGround == true then
        avatarWingsStillAnimation:draw(avatarWingsImage, avatar.x - avatar.w / 2, y, 0, 1 * scaleFactor, 1 * scaleFactor)
      else
        avatarWingsFlappingAnimation:draw(avatarWingsImage, avatar.x - avatar.w / 2, y, 0, 1 * scaleFactor, 1 * scaleFactor)
      end
    end

    -- draw avatar
    if avatar.isCrying == true then
      avatarCryingAnimation:draw(image, x, y, 0, avatar.direction * scaleFactor, 1 * scaleFactor)

    elseif avatar.flyingEnabled == true and avatar.isOnGround == false then
      avatarFlyingAnimation:draw(image, x, y, 0, avatar.direction * scaleFactor, 1 * scaleFactor)

    elseif avatar.isBesideWallLeft == true then
      avatarWalljumpAnimation:draw(image, avatar.x, y, 0, 1 * scaleFactor, 1 * scaleFactor)

    elseif avatar.isBesideWallRight == true then
      avatarWalljumpAnimation:draw(image, avatar.x + avatar.w, y, 0, -1 * scaleFactor, 1 * scaleFactor)

    elseif avatar.isOnGround == false and (avatar.crushingEnabled == true or avatar.invincibleEnabled == true) then
      avatarCrushingAnimation:draw(image, x, y, 0, avatar.direction * scaleFactor, 1 * scaleFactor)

    elseif avatar.isOnGround == false then
      avatarJumpingAnimation:draw(image, x, y, 0, avatar.direction * scaleFactor, 1 * scaleFactor)

    elseif math.abs(avatar.velx) < 1 then
      avatarStandingAnimation:draw(image, x, y, 0, avatar.direction * scaleFactor, 1 * scaleFactor)

    else
      avatarWalkingAnimation:draw(image, x, y, 0, avatar.direction * scaleFactor, 1 * scaleFactor)

    end

    -- reset color after drawing avatar
    love.graphics.setColor(fadingColor)
  end

  -- draw spikes and lava
  for i, tile in ipairs(level) do
    if tile.t == S and tile.isDeadly then
      love.graphics.draw(spikesImage, tile.x, tile.y)
    elseif tile.t == L then
      lavaAnimation:draw(lavaImage, tile.x, tile.y - tile.h)
    end
  end

  -- draw dead enemies
  for i, deadEnemy in ipairs(deadEnemies) do
    love.graphics.draw(enemyDeadImage, deadEnemy.x, deadEnemy.y)
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
