-- local startScreen = require('startScreen')
local screen = {}

screen.enter = function()
end

screen.exit = function()
end

screen.render = function(frame)
  love.graphics.setColor(Colors.red)
  love.graphics.print('YOU LOSE', 16,24,0,2)
end

screen.keypressed = function(key)
  if key=='return' then switchScreen(startScreen) end
end

return screen
