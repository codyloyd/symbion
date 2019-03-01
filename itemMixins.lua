itemMixins = {}

genericMixin = {
  name = 'genericMixin'
}

function genericMixin:init(opts)
  self.genericValue = opts and opts.genericValue or 8
end

function genericMixin:apply()
  print(self.name, self.genericValue)
end

itemMixins.genericMixin = genericMixin
