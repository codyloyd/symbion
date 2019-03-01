require('colors')
Glyph = {}
Glyph.new = function(opts) 
  local self = {}
  self.char = opts and opts.char or ' '
  self.tileset = opts and opts.tileset or 'Terrain'
  self.tileid = opts and opts.tileid or 15
  self.bitMask = nil
  self.bitMaskMap = opts and opts.bitMaskMap or nil
  self.fg = opts and opts.fg or Colors.white
  self.bg = opts and opts.bg or Colors.black

  if type(self.tileid) == 'table' then
    self.tileid = lume.randomchoice(self.tileid)
  end

  if self.bitMaskMap then
    for k,v in pairs(self.bitMaskMap) do
      if type(v) == 'table' then
        self.bitMaskMap[k] = lume.randomchoice(v)
      end
    end
  end

  if opts and opts.varyColor then
    self.fg = Colors.vary(self.fg, opts.varyColor)
  end

  return self
end
