ROT=require './lib/rotLove/src/rot'
require('colors')
require('loadTileset')
require('/lib/gooi')
Luvent = require('/lib/Luvent/src/Luvent')
inspect = require('/lib/inspect/inspect')
lume = require('/lib/lume')
local moonshine = require 'lib/moonshine'

love.window.setMode(1024,768)
love.graphics.setDefaultFilter('nearest', 'nearest')

local shakeTime, shakeDuration, shakeMagnitude = 0, -1, 0

function love.load()
  function width() return love.graphics.getWidth() end
  function height() return love.graphics.getHeight() end
  love.keyboard.setKeyRepeat(true)
  startScreen = require('startScreen')
  playScreen = require('playScreen')
  winScreen = require('winScreen')
  loseScreen = require('loseScreen')
  screenWidth = 40
  screenHeight = 14
  tilewidth = 16
  tileheight = 24
  flashScreenTime = 0
  flashScreenDuration = -1

  font = love.graphics.setNewFont('font/CP437.ttf', 16)
  bigFont = love.graphics.newFont('font/CP437.ttf', 48)
  charWidth = love.graphics.getFont():getWidth('e')
  charHeight = love.graphics.getFont():getHeight('e')


  switchScreen(startScreen)

  tiles = {}
  tiles.Terrain = loadTileset('img/Terrain.json')
  tiles.Terrain_Objects = loadTileset('img/Terrain_Objects.json')
  tiles.Monsters = loadTileset('img/Monsters.json')
  tiles.Avatar = loadTileset('img/Avatar.json')
  tiles.Items = loadTileset('img/Items.json')
  tiles.FX_Projectiles = loadTileset('img/FX_Projectiles.json')

  love.window.setMode(2*screenWidth*tilewidth,2*screenHeight*tileheight)

  mapCanvas = love.graphics.newCanvas()
  uiCanvas = love.graphics.newCanvas()
  flashCanvas = love.graphics.newCanvas()
  mapCanvas:setFilter('nearest', 'nearest')
  uiCanvas:setFilter('nearest', 'nearest')
  --GOOI stuff
  style = {
    font=font,
    bgColor = Colors.black,
    fgColor = Colors.white,
    radius = 2, -- raw pixels
    innerRadius = 2, -- raw pixels
    showBorder = true, -- border for components
    borderColor = component.colors.blue,
    borderWidth = love.window.toPixels(2), -- in pixels
    borderStyle = "smooth", -- or "smooth"
  }
  gooi.setStyle(style)
  gooi.desktopMode()

  gooi.shadow()

  effects = moonshine(moonshine.effects.glow)
  effects.glow.strength = 1.3
  effects.glow.min_luma = .6

end

function love.update(dt)
  gooi.update(dt)

  if currentScreen.update then
    currentScreen.update(dt)
  end

  if shakeTime < shakeDuration then
    shakeTime = shakeTime + dt
  end
  if flashScreenTime < flashScreenDuration then
    flashScreenTime = flashScreenTime + dt
  end

  love.graphics.setCanvas(flashCanvas)
    love.graphics.clear()
    love.graphics.setColor(Colors.pureWhite)
    love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setCanvas()
end

function love.draw()
  if shakeTime < shakeDuration then
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
    love.graphics.translate(dx, dy)
  end
  currentScreen.render(frame)
  if flashScreenTime < flashScreenDuration then
    love.graphics.setColor(.4,0,0,.5)
    love.graphics.draw(flashCanvas)
  end
end

function love.keypressed(key)
  if key=='z'then love.quit() end
  currentScreen.keypressed(key)
end

function love.mousepressed(x, y, button)  gooi.pressed() end
function love.mousereleased(x, y, button) gooi.released() end

function refresh()
  currentScreen.render(frame)
end

function switchScreen(screen)
  if currentScreen then
    currentScreen.exit()
  end
  currentScreen=screen
  if currentScreen then
    currentScreen.enter()
    refresh()
  end
end

function startShake(duration, magnitude)
    shakeTime, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end
function flashScreen(duration)
  flashScreenTime, flashScreenDuration = 0, duration or 1
end

--helpers

function getNeighborPositions(centerX, centerY)
  local tiles = {}
  for dx = -1, 1 do
    for dy = -1, 1 do
      if dx ~= 0 and dy ~= 0 then
        table.insert(tiles, {x = centerX + dx, y = centerY + dy})
      end
    end
  end
end

function splitString(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end
