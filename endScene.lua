love.graphics.setDefaultFilter('nearest', 'nearest')

local endImage
local gameOverMusic

local GRAPHICSSCALE
local SCREENWIDTH
local SCREENHEIGHT

function love.load()
  endImage = love.graphics.newImage('art/gameend.png')

  gameOverMusic = love.audio.newSource('sounds/music_gameover.wav')
  gameOverMusic:setLooping(true)
  gameOverMusic:play()

  -- set up graphics
  do
    local _, _, flags = love.window.getMode()
    SCREENWIDTH, SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)
    GRAPHICSSCALE = SCREENHEIGHT / endImage:getHeight()

    -- set fullscreen
    love.window.setFullscreen(true)

    -- set background color
    local BG_COLOR = {34, 32, 52, 255}
    love.graphics.setBackgroundColor(BG_COLOR)
  end
end

function love.keypressed(key)
  if key == 'z' then
    love.event.quit()
  end
end

function love.update(dt)
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.scale(GRAPHICSSCALE)
  love.graphics.draw(endImage, (SCREENWIDTH / GRAPHICSSCALE - endImage:getWidth()) / 2, 0)
end
