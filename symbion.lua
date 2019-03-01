require('colors')
require('mixins')
require('glyph')

Symbion = {}
Symbion.templates = {}
Symbion.new = function(opts)
  local self = {}
  local glyph = Glyph.new(opts)
  for k,v in pairs(glyph) do
    self[k] = v
  end

  self.name = opts and opts.name or 'Symbion'

  -- mixin system
  self.attachedMixins = {}
  self.attachedMixinGroups = {}
  mixins = opts and opts.mixins
  if mixins then
    for _,mixinName in ipairs(mixins) do
      local mixin = Mixins[mixinName]
      for key,value in pairs(mixin) do
        if key ~= 'init' and key ~= 'name' then
          self[key] = value
        end
      end
      self.attachedMixins[mixin.name] = true
      if mixin.groupName then
        self.attachedMixinGroups[mixin.groupName] = true
      end
      if mixin.init then
        mixin.init(self, opts)
      end
    end
  end

  self.hasMixin = function(self, mixin)
    if type(mixin) == 'table' then
      return self.attachedMixins[mixin.name]
    elseif type(mixin) == 'string' then
      return self.attachedMixins[mixin] or self.attachedMixinGroups[mixin]
    end
  end

  return self
end

Symbion.SpeedyTemplate = {
  mixins = {"Speedy"},
  tileset = 'Monsters',
  tileid = 93,
  fg = Colors.lightGreen,
  name="Frank"
}

Mixins.Speedy = {
  name = 'Speedy'
}

function Mixins.Speedy:init()
  self.randomNumber = math.random(0,100)
  self.maxLife = 20
  self.life = self.maxLife
  self.isAttached = false
end

function Mixins.Speedy:update()
  print(self.name)
  if self.isAttached then
    self.life = self.life - 1
    updateUi:trigger('symbionBar', self.life/self.maxLife)
    if self.life <= 0 then
      print('THIS GUY FREAKIN DIED LOSER')
    end
  else
    self.life = math.min(self.life + 1, self.maxLife)
  end
end

function Mixins.Speedy:apply(player)
  if self.life/self.maxLife > .4 then
    self.isAttached = true
    player.attachedSymbion = self
    player.speedModifier = 3
    return true
  end
  return false
end

function Mixins.Speedy:remove(player)
  self.isAttached = false
  player.attachedSymbion = nil
  player.speedModifier = 1
end

Symbion.PunchyTemplate = {
  mixins = {"Punchy"},
  tileset = 'Monsters',
  tileid = 459,
  fg = Colors.lightBlue,
  name="Carlos"
}

Mixins.Punchy = {
  name = 'Punchy'
}

function Mixins.Punchy:init()
  self.maxLife = 20
  self.life = self.maxLife
  self.isAttached = false
end

function Mixins.Punchy:update()
  print(self.name)
  if self.isAttached then
    self.life = self.life - 1
    updateUi:trigger('symbionBar', self.life/self.maxLife)
    if self.life <= 0 then
      print('THIS GUY FREAKIN DIED LOSER')
    end
  else
    self.life = math.min(self.life + 1, self.maxLife)
  end
end

function Mixins.Punchy:apply(player)
  if self.life/self.maxLife > .4 then
    self.isAttached = true
    player.attachedSymbion = self
    player.attackModifier = 3
    return true
  end
  return false
end

function Mixins.Punchy:remove(player)
  self.isAttached = false
  player.attachedSymbion = nil
  player.attackModifier = 1
end
