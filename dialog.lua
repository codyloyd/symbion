Dialog = {}

Dialog.new = function(opts)
  local self = {}
  local text = opts and opts.text or nil
  local maxWidth = 2*screenWidth * charWidth - (8 * charWidth)
  local maxHeight = 2*screenHeight * charHeight - (8 * charWidth)
  local outerCanvas = love.graphics.newCanvas()
  local innerCanvas = love.graphics.newCanvas()
  self.renderContent = false

  if text then
    self.width = string.len(text) * charWidth + 2 * charWidth
    self.height = charHeight * math.ceil(width/(maxWidth - 2 * charWidth)) + 2 * charHeight
  else
    self.width = opts and opts.width or maxWidth
    self.height = opts and opts.height or maxHeight
  end


  function self:render()
    love.graphics.setCanvas(outerCanvas)
    love.graphics.setColor(Colors.black)
    love.graphics.rectangle('fill', 0, 0, math.min(self.width, maxWidth), math.min(self.height, maxHeight))

    love.graphics.setColor(Colors.lightGray)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', 0, 0, math.min(self.width, maxWidth), math.min(self.height, maxHeight))

    love.graphics.setColor(Colors.white)

    if self.renderContent or not text then
      if self.clear then
      love.graphics.setCanvas(innerCanvas)
        love.graphics.setColor(Colors.black)
        love.graphics.rectangle('fill', 0, 0, math.min(self.width, maxWidth)-2*charWidth, math.min(self.height, maxHeight)-2*charHeight)
        self.clear = false
        return
      love.graphics.setCanvas()
      else
      love.graphics.setCanvas(innerCanvas)
        self:renderContent()
      love.graphics.setCanvas()
      end
    else
      love.graphics.printf(text, 0, 0, maxWidth - 2*charWidth, 'left')
    end
    love.graphics.setCanvas()

    love.graphics.setColor(Colors.pureWhite)
    love.graphics.draw(outerCanvas, 2*charWidth, 2*charHeight, 0, 2)
    love.graphics.draw(innerCanvas, 4*charWidth,4*charHeight,0,2)
  end


  function self:keypressed(key)
  end

  return self
end
