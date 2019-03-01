require('tile')
require('map')
require('entity')
require('item')

Level = {}
function Level.new(opts)
  local self = {}
  self.entities = {}
  self.items = {}
  self.mapStyle = opts and opts.mapStyle or 'forest'
  self.map = Map.new({mapStyle=self.mapStyle})
  self.exploredTiles = {}

  function self.getEntityAt(x,y) 
    for _,entity in pairs(self.entities) do
      if entity.x == x and entity.y == y then
        return entity
      end 
    end
    return false
  end

  function self.getEntitiesWithinRadius(centerX, centerY, radius)
    local results = {}
    local leftX, rightX = centerX - radius, centerX + radius
    local topY, bottomY = centerY - radius, centerY + radius
    for _, entity in pairs(self.entities) do
      if entity.x >= leftX and entity.x <= rightX and entity.y >= topY and entity.y <= bottomY then
        table.insert(results, entity)
      end
    end
    return results
  end

  function self.addEntity(entity)
    if entity.x < 0 and entity.x >= self.map.width or
      entity.y < 0 or entity.y >= self.map.height then
        -- throw error.. oops
    end
    entity.level = self
    entity.map = self.map
    table.insert(self.entities, entity)
    if entity:hasMixin('Actor') then scheduler:add(entity, true) end
  end

  function self.removeEntity(entityToRemove)
    for i, entity in pairs(self.entities) do
      if entity == entityToRemove then
        table.remove(self.entities, i)
        if entity:hasMixin('Actor') then
          scheduler:remove(entity) 
        end
      end
    end
  end

  function self.addItem(item, x, y)
    if self.isEmptyFloor(x, y) then
      self.items[x..','..y] = item
      return true
    end
    return false
  end

  function self.removeItem(itemToRemove)
    for key, item in pairs(self.items) do
      if item == itemToRemove then
        self.items[key] = null
      end
    end
  end

  function self.addItemAtRandomPosition(item)
    local x, y = self.getRandomFloorPosition()
    self.addItem(item, x, y)
  end

  function self.isEmptyFloor(x, y)
    return self.map.getTile(x, y) and self.map.getTile(x,y).name == 'floorTile' and not self.getEntityAt(x,y)
  end

  function self.getRandomFloorPosition()
    local x, y
    repeat
      x, y = math.random(1,self.map.width), math.random(1,self.map.height)
    until (self.isEmptyFloor(x, y))
    return x, y
  end

  function self.addEntityAtRandomPosition(entity)
    entity.x, entity.y = self.getRandomFloorPosition()
    self.addEntity(entity)
  end

  -- add entities to map
  -- for i=1, 3 do
  --   local entity = Entity.new(Entity.FungusTemplate)
  --   self.addEntityAtRandomPosition(entity)
  -- end
  -- for i=1, 7 do
  --   local entity = Entity.new(Entity.MonsterTemplate)
  --   self.addEntityAtRandomPosition(entity)
  -- end
  -- for i=1, 5 do
  --   local entity = Entity.new(Entity.BatTemplate)
  --   self.addEntityAtRandomPosition(entity)
  -- end
  for i=1,17 do
    local entity = Entity.new(Entity.randomEntity())
    self.addEntityAtRandomPosition(entity)
  end
    -- add Items
  for i=1, 19 do
    local item = Item.new(Item.randomItem())
    self.addItemAtRandomPosition(item)
  end
  -- add downstairs
  self.downstairs = {}
  self.downstairs.x, self.downstairs.y = self.getRandomFloorPosition()
  self.map.setTile(self.downstairs.x, self.downstairs.y, Tile.stairDownTile)
  -- add upstairs
  self.upstairs = {}
  self.upstairs.x, self.upstairs.y = self.getRandomFloorPosition()
  self.map.setTile(self.upstairs.x, self.upstairs.y, Tile.stairUpTile)
  return self
end
