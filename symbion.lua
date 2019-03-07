require('colors')
require('mixins')
require('glyph')

Symbion = {}
Symbion.templates = {}
Symbion.new = function(opts)
  opts.tileid = lume.randomchoice(Symbion.tiles)
  opts.tileset = 'Monsters'
  opts.fg = lume.randomchoice(Symbion.colors)
  local self = {}
  local glyph = Glyph.new(opts)
  for k,v in pairs(glyph) do
    self[k] = v
  end

  self.name = opts and opts.name or lume.randomchoice(Symbion.names)
  self.desc = opts and opts.desc or 'a little weenie of a slug'
  self.isAttached = false
  self.maxLife = opts and opts.maxLife or 20
  self.life = opts and opts.life or self.maxLife

  -- mixin system
  self.applyFunctions = {}
  self.removeFunctions = {}
  self.attachedMixins = {}
  self.attachedMixinGroups = {}
  mixins = opts and opts.mixins
  if mixins then
    for _,mixinName in ipairs(mixins) do
      local mixin = Mixins[mixinName]
      for key,value in pairs(mixin) do
        if key ~= 'init' and key ~= 'name' and key ~= 'apply' and key ~= 'remove' then
          self[key] = value
        end
      end
      self.attachedMixins[mixin.name] = true
      if mixin.groupName then
        self.attachedMixinGroups[mixin.groupName] = true
      end
      if mixin.apply then
        table.insert(self.applyFunctions, mixin.apply)
      end
      if mixin.remove then
        table.insert(self.removeFunctions, mixin.remove)
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

  function self:update()
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

  function self.kill()
    self.dead = true;
    updateUi:trigger('symbionGui', 'hide')
    self:remove(player)
    lume.remove(player.symbions, self)
  end

  function self:apply(player)
    if self.life/self.maxLife > .4 then
      player.attachedSymbion = self
      self.isAttached = true
      lume.each(self.applyFunctions, function(fun)
        fun(self, player)
      end)
      return true
    end
  end

  function self:remove(player)
    self.isAttached = false
    player.attachedSymbion = nil
    lume.each(self.removeFunctions, function(fun)
      fun(self, player)
    end)
  end

  return self
end

Symbion.tiles = {93,94,266,277,280,310,474,459,458,349,84,320,117,122,340}
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
"Carlos",
"Ryan",
"Peen",
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
"Dhivloo",
"Lochkit",
"Newtpaw",
"Seedstar",
"Birdwater",
"Bearrock",
"Marigoldlight",
"Driftsun",
"Crowkit",
"Rockpaw",
"Stormstar",
"Curlnose",
"Otterbelly",
"Birdblossom",
"Harescar"
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
  desc="Increases speed 2x"
}
Symbion.templates.Speedy2 = {
  mixins = {"Speedy"},
  desc="Increases speed 3x",
  speedModifier=3
}
Symbion.templates.Speedy3 = {
  mixins = {"Speedy","Punchy"},
  desc="Increases speed 4x, but lowers attack power by 25%",
  speedModifier=4,
  attackModifier=.75
}
Symbion.templates.Speedy4 = {
  mixins = {"Speedy","Punchy"},
  desc="Increases speed 6x, but lowers attack power by 75%",
  speedModifier=6,
  attackModifier=.25
}
Symbion.templates.Punchy = {
  mixins = {"Punchy"},
  desc="increases attack power 2x"
}
Symbion.templates.Punchy2 = {
  mixins = {"Punchy"},
  desc="increases attack power 3x",
  attackModifier=3
}
Symbion.templates.Punchy3 = {
  mixins = {"Punchy", "Speedy"},
  desc="increases attack power 4x, lowers speed by 25%",
  attackModifier=4,
  speedModifier=.75
}
Symbion.templates.FastPunchy = {
  mixins = {"Punchy", "Speedy"},
  desc="Increases Speed 2x and increases attack 2x."
}
Symbion.templates.HealthRegen = {
  mixins={"HealthRegen"},
  desc="Allows you to regenerate health, 1hp per 2 turns"
}
Symbion.templates.HealthRegen2 = {
  mixins={"HealthRegen"},
  desc="Allows you to regenerate health, 1hp per turn",
  healthRegenRate=1
}
Symbion.templates.HealthRegen3 = {
  mixins={"HealthRegen"},
  desc="Allows you to regenerate health, 2hp per  turn",
  healthRegenRate=2
}
Symbion.templates.stunner = {
  mixins = {"Stun"},
  desc="stuns enemies adjacent to you for 4 turns"
}
Symbion.templates.stunner2 = {
  mixins = {"Stun"},
  desc="stuns enemies adjacent to you for 5 turns",
  stunDuration = 5
}
Symbion.templates.stunner3 = {
  mixins = {"Stun"},
  desc="stuns enemies adjacent to you for 6 turns",
  stunDuration = 6
}
Symbion.templates.stunner4 = {
  mixins={"Stun"},
  desc="stuns enemies that are within 3 spaces you for 8 turns",
  abilityCost = 12,
  stunDuration = 8,
  stunRadius = 3
}
Symbion.templates.kill = {
  mixins={'Fireball'},
  desc="allows you to shoot a weak fireball within a range of 2 squares",
  fireballDamage = 6,
  fireballRange = 2
}
Symbion.templates.kill2 = {
  mixins={'Fireball'},
  desc="allows you to shoot a fairly powerful fireball within a range of 3 squares",
  abilityCost = 8,
  fireballDamage = 16,
  fireballRange = 3
}
Symbion.templates.kill3 = {
  mixins={'Fireball', 'Speedy'},
  desc="allows you to shoot a amazingly powerful fireball within a range of 4 squares, also makes you 50% slower",
  abilityCost = 8,
  speedModifier = .5,
  fireballDamage = 36,
  fireballRange = 4
}
Symbion.templates.shooter = {
  mixins={'ProjectileShooter'},
  desc="allows you to shoot projectiles in every direction",
  projectileSpeed = 2000
}


Mixins.Speedy = {
  name = 'Speedy'
}

function Mixins.Speedy:init(opts)
  self.speedModifier = opts and opts.speedModifier or 2
end

function Mixins.Speedy.apply(self, player)
  player.speedModifier = self.speedModifier
end

function Mixins.Speedy.remove(self, player)
  player.speedModifier = 1
end


Mixins.Punchy = {
  name = 'Punchy'
}

function Mixins.Punchy:init(opts)
  self.attackModifier = opts and opts.attackModifier or 2
end

function Mixins.Punchy:apply(player)
    player.attackModifier = self.attackModifier 
end

function Mixins.Punchy:remove(player)
  player.attackModifier = 1
end

Mixins.HealthRegen = {
  name='HealthRegen'
}
function Mixins.HealthRegen:init(opts)
  self.healthRegenRate = opts and opts.healthRegenRate or .5
end

function Mixins.HealthRegen:apply()
  player.healthRegenRate = self.healthRegenRate
end

function Mixins.HealthRegen:remove()
  player.healthRegenRate = 0
end


Mixins.ProjectileShooter = {
  name="ProjectileShooter"
}

function Mixins.ProjectileShooter:init(opts)
  self.projectileSpeed = opts and opts.projectileSpeed or 1500
  self.abilityCost = opts and opts.abilityCost or 5
end

function Mixins.ProjectileShooter:ability(player)
  self.life = self.life - self.abilityCost
  local level = gameWorld:getCurrentLevel()
  for x=-1,1 do
    for y=-1,1 do
      if x == 0 and y == 0 then
      else
        local newProjectile = Entity.new(Entity.templates.playerProjectile) 
        newProjectile.direction = {x,y}
        newProjectile.speed = self.projectileSpeed
        newProjectile.x, newProjectile.y = player.x, player.y
        level.addEntity(newProjectile)
      end
    end
  end
end

Mixins.Stun = {
  name="Stun"
}

function Mixins.Stun:init(opts)
  self.stunRadius = opts and opts.stunRadius or 1
  self.stunDuration = opts and opts.stunDuration or 4
  self.abilityCost = opts and opts.abilityCost or 5
end

function Mixins.Stun:ability(player)
  self.life = self.life - self.abilityCost
  local entities = gameWorld:getCurrentLevel().getEntitiesWithinRadius(player.x, player.y, self.stunRadius)
  lume.each(entities, function(entity)
    entity:stun(self.stunDuration)
  end)
end

Mixins.Fireball = {
  name='Fireball'
}
function Mixins.Fireball:init(opts)
  self.fireballDamage = opts and opts.fireballDamage or 10
  self.fireballRange = opts and opts.fireballRange or 2
  self.abilityCost = opts and opts.abilityCost or 5
end

function Mixins.Fireball:ability(player)
  self.life = self.life - self.abilityCost
  targetSomething(self.fireballRange, function(x,y)
    local target = gameWorld:getCurrentLevel().getEntityAt(x,y)
    if target and target:hasMixin('Destructible') then
      local topLeftX = math.max(1, player.x - (screenWidth / 2))
      local topLeftX = math.min(topLeftX, mapWidth - screenWidth)
      local topLeftY = math.max(1, player.y - (screenHeight / 2))
      local topLeftY = math.min(topLeftY, mapHeight - screenHeight)

      fireworks((x-topLeftX)*2*tilewidth+tilewidth,(y-topLeftY)*2*tileheight+tileheight, target.fg)
      target:takeDamage(player, self.fireballDamage)
    end
  end)
end

