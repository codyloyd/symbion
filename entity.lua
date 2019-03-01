require('colors')
require('mixins')
require('glyph')

Entity = {}
Entity.templates = {}
Entity.new = function(opts)
  self = {}
  local glyph = Glyph.new(opts)
  for k,v in pairs(glyph) do
    self[k] = v
  end
  self.name = opts and opts.name or 'ENTITY'
  self.x = opts and opts.x or 0
  self.y = opts and opts.y or 0
  self.map = opts and opts.map
  self.speed = opts and opts.speed or 1000

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

  function self:getSpeed() return self.speed end

  return self
end

Entity.randomEntity = function()
  local keys = {}
  for key, value in pairs(Entity.templates) do
    keys[#keys+1] = key --Store keys in another table
  end
  index = keys[math.random(1, #keys)]
  return Entity.templates[index]
end

  -- load items from org file
local fileContents = love.filesystem.read("entities.org")
local lines = splitString(fileContents, '\n')
local headers = splitString(lines[1], "|")
for i,item in ipairs(headers) do
  headers[i] = item:gsub("%s+", "")
end

itemsArray = {}
for i,item in ipairs(lines) do
  if i > 1 then
    local newItem = {}
    local values = splitString(lines[i], "|")
    for i,value in ipairs(values) do
      newItem[headers[i]] = value:gsub("%s+", "")
    end
    table.insert(itemsArray, newItem)
  end
end

for _,fields in ipairs( itemsArray ) do
  if fields.fg then
    fields.fg = Colors[fields.fg]
  end
  if fields.bg then
    fields.bg = Colors[fields.bg]
  end
  if fields.mixins then
    fields.mixins = splitString(fields.mixins, ',')
  end

  if fields.name and string.find(fields.name, "-") then

  else
    Entity.templates[fields.name] = fields
  end
end

Entity.PlayerTemplate = {
  name = 'You', 
  char = '@',
  tileset = 'Avatar',
  tileid = 1,
  fg = Colors.pureWhite,
  bg = Colors.black,
  maxHp = 40,
  attackValue = 10,
  mixins = {"Movable","PlayerActor","Destructible","Attacker","MessageRecipient","InventoryHolder"}
}

Entity.FungusTemplate = {
  name = 'fungus',
  char = 'F',
  tileset = 'Terrain_Objects',
  tileid = 93,
  fg = Colors.green,
  bg = Colors.black,
  maxHp = 10,
  speed = 250,
  mixins = {Mixins.FungusActor, Mixins.Destructible}
}

Entity.MonsterTemplate = {
  name = 'monster',
  char = 'M',
  tileset = 'Monsters',
  tileid = 273,
  fg = Colors.orange,
  bg = Colors.black,
  maxHp = 10,
  speed = 900,
  sightRadius = 8,
  mixins = {Mixins.Movable, Mixins.Attacker, Mixins.MonsterActor, Mixins.Destructible, Mixins.Sight}
}

Entity.BatTemplate = {
  name = 'bat',
  char = 'b',
  tileset = 'Monsters',
  tileid = 82,
  fg = Colors.blue,
  bg = Colors.black,
  maxHp = 10,
  speed = 1600,
  sightRadius = 10,
  mixins = {Mixins.Movable, Mixins.Attacker, Mixins.MonsterActor, Mixins.Destructible, Mixins.Sight}
}
