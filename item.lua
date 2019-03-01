require('colors')
require('itemMixins')
require('glyph')

Item = {}
Item.templates = {}
Item.new = function(opts)
  self = {}
  local glyph = Glyph.new(opts)
  for k,v in pairs(glyph) do
    self[k] = v
  end
  self.name = opts and opts.name or 'ITEM'

  -- mixin system
  self.attachedMixins = {}
  self.attachedMixinGroups = {}
  mixins = opts and opts.mixins
  if mixins then
    for _,mixin in ipairs(mixins) do
      mixin = itemMixins[mixin]
      if mixin then
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

Item.randomItem = function()
  local keys = {}
  for key, value in pairs(Item.templates) do
    keys[#keys+1] = key --Store keys in another table
  end
  index = keys[math.random(1, #keys)]
  return Item.templates[index]
end

  -- load items from org file
local fileContents = love.filesystem.read("items.org")
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

for i,fields in ipairs( itemsArray  )do
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
    Item.templates[fields.name] = fields
  end
end


