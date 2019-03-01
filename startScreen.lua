-- local playScreen = require('playScreen')
local screen = {}
local title
screen.enter = function()
  title = love.graphics.newImage('/img/title.png')
end

screen.exit = function()
  love.graphics.setFont(font)
end

screen.render = function(frame)
  love.graphics.clear(Colors.black)
  love.graphics.draw(title, love.graphics.getWidth()/2 - (title:getWidth()*2), 100, 0, 4, 4)
  love.graphics.setColor(Colors.white)
  love.graphics.setFont(bigFont)
  love.graphics.printf('press enter', 0, 600, love.graphics.getWidth(), 'center')
end

screen.keypressed = function(key)
  if key=='return' then 
    switchScreen(playScreen)
  end
end

return screen
