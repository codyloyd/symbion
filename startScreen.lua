-- local playScreen = require('playScreen')
local screen = {}

screen.enter = function()
end

screen.exit = function()
end

screen.render = function(frame)
  love.graphics.setColor(Colors.white)
  love.graphics.print("LOOK AT ME I'M A ROGUELIKE WRITTEN", 16, 24, 0, 2)
  love.graphics.setColor(Colors.blue)
  love.graphics.print("in LUA", 16, 48, 0, 8)
end

screen.keypressed = function(key)
  if key=='return' then 
    switchScreen(playScreen)
  end
end

return screen
