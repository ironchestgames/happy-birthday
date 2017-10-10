love.graphics.setDefaultFilter('nearest', 'nearest')

local stateswitcher = require("stateswitcher")

local levelDoneImage
local levelDoneCrossImage
local levelDoneSceneSound

local PRECROSSDURATION = 1
local POSTCROSSDURATION = 2
local durationCount = 0
local isCrossPlayed = false

local GRAPHICSSCALE
local SCREENWIDTH
local SCREENHEIGHT

function love.load()
  levelDoneImage = love.graphics.newImage('art/leveldone.png')
  levelDoneCrossImage = love.graphics.newImage('art/leveldone_cross.png')

  levelDoneSceneSound = love.audio.newSource('sounds/leveldonecross.ogg', 'static')

  -- set up graphics
  do
    local _, _, flags = love.window.getMode()
    SCREENWIDTH, SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)
    GRAPHICSSCALE = SCREENHEIGHT / levelDoneImage:getHeight()

    -- set fullscreen
    love.window.setFullscreen(true)

    -- set background color
    local BG_COLOR = {34, 32, 52, 255}
    love.graphics.setBackgroundColor(BG_COLOR)

  end
end

function love.keypressed(key)
end

function love.update(dt)
  durationCount = durationCount + dt

  if isCrossPlayed == false and durationCount > PRECROSSDURATION then
    isCrossPlayed = true

    levelDoneSceneSound:play()
  end

  if durationCount > PRECROSSDURATION + POSTCROSSDURATION then
    stateswitcher.switch('gameScene', {currentLevelIndex = passvar.currentLevelIndex})
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.scale(GRAPHICSSCALE)
  love.graphics.draw(levelDoneImage, (SCREENWIDTH / GRAPHICSSCALE - levelDoneImage:getWidth()) / 2, 0)

  for i = 1, passvar.currentLevelIndex - 2 do
    love.graphics.draw(
        levelDoneCrossImage,
        (SCREENWIDTH / GRAPHICSSCALE - levelDoneCrossImage:getWidth()) / 2,
        (i - 1) * (9 + levelDoneCrossImage:getHeight()) + 31)
  end

  if isCrossPlayed == true then
    love.graphics.draw(
        levelDoneCrossImage,
        (SCREENWIDTH / GRAPHICSSCALE - levelDoneCrossImage:getWidth()) / 2,
        (passvar.currentLevelIndex - 2) * (9 + levelDoneCrossImage:getHeight()) + 31)
  end
end
