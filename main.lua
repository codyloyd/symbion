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

  font = love.graphics.setNewFont('font/CP437.ttf', 16)
  charWidth = love.graphics.getFont():getWidth('e')
  charHeight = love.graphics.getFont():getHeight('e')

  scheduler=ROT.Scheduler.Speed:new()
  engine=ROT.Engine:new(scheduler)
  engine:start()

  switchScreen(startScreen)

  tiles = {}
  tiles.Terrain = loadTileset('img/Terrain.json')
  tiles.Terrain_Objects = loadTileset('img/Terrain_Objects.json')
  tiles.Monsters = loadTileset('img/Monsters.json')
  tiles.Avatar = loadTileset('img/Avatar.json')
  tiles.Items = loadTileset('img/Items.json')

  love.window.setMode(2*screenWidth*tilewidth,2*screenHeight*tileheight)

  mapCanvas = love.graphics.newCanvas()
  uiCanvas = love.graphics.newCanvas()
  mapCanvas:setFilter('nearest', 'nearest')
  uiCanvas:setFilter('nearest', 'nearest')
  --GOOI stuff
  style = {
    font=font,
    radius = 0,
    innerRadius = 0,
    showBorder = true,
    bgColor = {0.208, 0.220, 0.222}
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
end

function love.draw()
  currentScreen.render(frame)
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

--helpers

function sendMessage(recipient, message)
  if recipient:hasMixin('MessageRecipient') then
    recipient:receiveMessage(message)
  end
end

function sendMessageNearby(level, x, y, message)
  local entities = level.getEntitiesWithinRadius(x,y,5)
  for _, entity in pairs(entities) do
    sendMessage(entity, message)
  end
end

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
