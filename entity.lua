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
  self.noRandom = opts and opts.noRandom or false
  self.speedModifier = 1
  self.hitDuration = -1
  self.hitTime = 0
  self.canStun = false
  self.stunnedTime = 0


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

  function self:getAngle()
    if self.direction then
      return lume.angle(0,0,self.direction[1], self.direction[2]) + 1.570796
    end
    return false
  end

  function self:stun(time)
    if self.canStun then
      self.stunnedTime =  time or 3
    end
  end

  function self:hit()
    self.hitTime, self.hitDuration = 0, .1
  end

  function self:getSpeed() 
    return self.speed * self.speedModifier
  end

  return self
end

Entity.randomEntity = function(level)
  local leveledTempates = lume.filter(Entity.templates, function(e)
    local lowerBound = tonumber(e.lowestLevel) or 0
    local higherBound =  tonumber(e.highestLevel) or 100
    return level >= lowerBound and level <= higherBound
  end, true)
  local keys = {}
  for key, value in pairs(leveledTempates) do 
    if not value.noRandom then
      keys[#keys+1] = key --Store keys in another table
    end
  end
  local index = keys[math.random(1, #keys)]
  local ent =  Entity.templates[index]
  return ent
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
      if newItem[headers[i]] == '' then
        newItem[headers[i]] = nil
      end
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
  maxHp = 50,
  attackValue = 6,
  mixins = {"Movable","PlayerActor","Destructible","Attacker","InventoryHolder","SymbionUser"}
}
