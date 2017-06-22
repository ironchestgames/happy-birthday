love.graphics.setDefaultFilter('nearest', 'nearest')

local stateswitcher = require("stateswitcher")

local splashImage
local instructionsImage

local isShowingInstructions = false

local GRAPHICSSCALE
local SCREENWIDTH
local SCREENHEIGHT

function love.load()
  splashImage = love.graphics.newImage('art/splash.png')
  instructionsImage = love.graphics.newImage('art/instructions.png')

  -- set up graphics
  do
    local _, _, flags = love.window.getMode()
    SCREENWIDTH, SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)
    GRAPHICSSCALE = SCREENHEIGHT / splashImage:getHeight()

    -- set fullscreen
    love.window.setFullscreen(true)

    -- set background color
    local BG_COLOR = {34, 32, 52, 255}
    love.graphics.setBackgroundColor(BG_COLOR)
  end
end

function love.keypressed(key)
  if key == 'z' then
    if isShowingInstructions == false then
      isShowingInstructions = true
    else
      stateswitcher.switch('gameScene')
    end
  end
end

function love.draw()
  love.graphics.scale(GRAPHICSSCALE)
  local image = splashImage
  if isShowingInstructions == true then
    image = instructionsImage
  end
  love.graphics.draw(image, (SCREENWIDTH / GRAPHICSSCALE - splashImage:getWidth()) / 2, 0)
end