require('tile')
require('map')
require('entity')
require('item')

Level = {}
function Level.new(opts)
  local self = {}
  self.entities = {}
  self.items = {}
  self.symbions = {}
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
    local count = 1
    for i, entity in pairs(self.entities) do
      count = count + 1
      if entity == entityToRemove then
        table.remove(self.entities, i)
        if entity:hasMixin('Actor') then
          scheduler:remove(entity) 
        end
      end
    end
  end

  function self.addSymbion(symbion, x, y)
    self.symbions[x..','..y] = symbion
    return true
  end

  function self.removeSymbion(symbionToRemove)
    for key, symb in pairs(self.symbions) do
      if symb == symbionToRemove then
        self.symbions[key] = null
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
    local tile = self.map.getTile(x,y)
    if tile then
      return (tile.name =='floorTile' or tile.name=='islandTile') and not self.getEntityAt(x,y)
    end
    return false
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

  if opts.mapStyle == "boss" then
    self.addEntityAtRandomPosition(Entity.new(Entity.templates.Chelzrath))
  else
    for i=1, 4 do
      if math.random(10) < 8 then
        self.addEntityAtRandomPosition(Entity.new(Entity.templates.symbionEgg))
      end
    end
  end

  local enemies = 20
  if opts.mapStyle == "forest" then enemies = 10 end
  for i=1,enemies do
    local entity = Entity.new(Entity.randomEntity())
    self.addEntityAtRandomPosition(entity)
  end

  -- add downstairs
  if opts.mapStyle ~= "boss" then
    self.downstairs = {}
    self.downstairs.x, self.downstairs.y = self.getRandomFloorPosition()
    self.map.setTile(self.downstairs.x, self.downstairs.y, Tile.stairDownTile)
  end
  -- add upstairs
  if opts.mapStyle ~= "forest" then 
    self.upstairs = {}
    self.upstairs.x, self.upstairs.y = self.getRandomFloorPosition()
    self.map.setTile(self.upstairs.x, self.upstairs.y, Tile.stairUpTile)
  end 
  return self
end
