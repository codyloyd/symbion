require('colors')
require('mixins')
require('glyph')

Symbion = {}
Symbion.templates = {}
Symbion.new = function(opts)
  opts.tileid = lume.randomchoice(Symbion.tiles)
  opts.fg = lume.randomchoice(Symbion.colors)
  local self = {}
  local glyph = Glyph.new(opts)
  for k,v in pairs(glyph) do
    self[k] = v
  end

  self.name = opts and opts.name or lume.randomchoice(Symbion.names)
  self.desc = opts and opts.desc or 'a little weenie of a slug'

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

  function self.kill()
    self.dead = true;
    updateUi:trigger('symbionGui', 'hide')
    self:remove(player)
    lume.remove(player.symbions, self)
  end

  return self
end

Symbion.tiles = {93,94,266,277,280,310,474,459,458,349,84,320}
Symbion.colors = {
  Colors.lightGray,
  Colors.brown,
  Colors.lightBrown,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.lightGreen,
  Colors.green,
  Colors.blue,
  Colors.lightBlue
}
Symbion.names = {
"Bhulk",
"Jac",
"Rooc",
"Dur",
"Dhanran",
"Gazdar",
"Zonrit",
"Guvin",
"Toulrac",
"Dhule",
"Jhalga",
"Cobbu",
"Daasai",
"Dafno",
"Turti",
"Aivlis",
"Zaelan",
"Stutee",
"Helmol",
"Zemkill",
"Skazoh",
"Ghecni",
"Gnalkai",
"Botec",
"Resrut",
"Cigolk",
"Ruddull",
"Jaknog",
"Brootair",
"Thulgee",
"Sciyru",
"Ghodiad",
"Diyren",
"Kreteb",
"Ghiggaan",
"Rerab",
"Flavnall",
"Dhivloo"
}

Symbion.randomSymbion = function()
  local keys = {}
  for key, value in pairs(Symbion.templates) do 
    if not value.noRandom then
      keys[#keys+1] = key --Store keys in another table
    end
  end
  index = keys[math.random(1, #keys)]
  return Symbion.templates[index]
end

Symbion.templates.Speedy = {
  mixins = {"Speedy"},
  tileset = 'Monsters',
  desc="This small prickly little fella will increase your speed.  Useful when making a run for it!"
}

Mixins.Speedy = {
  name = 'Speedy'
}

function Mixins.Speedy:init()
  self.maxLife = 20
  self.life = self.maxLife
  self.isAttached = false
end

function Mixins.Speedy:update()
  if self.isAttached then
    self.life = self.life - 1
    updateUi:trigger('symbionBar', self.life/self.maxLife)
    if self.life <= 0 then
      player.attachedSymbion = nil
      self.kill()
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

Symbion.templates.Punchy = {
  mixins = {"Punchy"},
  tileset = 'Monsters',
  desc="A fat little guy and is heavier than he looks.  He'll increase your attack power significantly."
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
  if self.isAttached then
    self.life = self.life - 1
    updateUi:trigger('symbionBar', self.life/self.maxLife)
    if self.life <= 0 then
      player.attachedSymbion = nil
      self.kill()
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
