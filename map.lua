ROT=require './lib/rotLove/src/rot'

Map = {}
Map.new = function(opts)
  local self = {}
  self.tiles = {}
  mapWidth = 100
  mapHeight = 30 
  self.width = mapWidth
  self.height = mapHeight

  function self.getTile(x,y)
    if x > 0 and x < self.width and y > 0 and y < self.height then
      return self.tiles[x][y]
    end
  end

  function self.setTile(x, y, tile)
    if self.tiles[x] and self.tiles[x][y] then
      self.tiles[x][y] = tile
    end
  end

  -- fill map with empty tiles
  for x = 1, mapWidth do
    self.tiles[x] = {}
    for y = 1, mapHeight do
      self.tiles[x][y] = Tile.nullTile
    end
  end


  if opts and opts.mapStyle == 'forest' then
    -- forest
    local gen = ROT.Map.Cellular:new(mapWidth,mapHeight,{
      connected=true,
      born={6,7,8},
      survive={2,3,4,5}
    })
    gen:randomize(.2)
    gen:create(function(x,y,val)
      if val == 0 then
        self.tiles[x][y] = Tile.new(Tile.floorTile)
      elseif val == 1 then
        self.tiles[x][y] = Tile.new(Tile.treeTile)
      end
    end)
  elseif opts and opts.mapStyle == 'cave' then
      --cave
    local gen = ROT.Map.Cellular:new(mapWidth,mapHeight,{
      connected=true,
      topology=8
    })
    gen:randomize(.4)
    gen:create(function(x,y,val)
      if val == 0 then
        self.tiles[x][y] = Tile.new(Tile.floorTile)
      elseif val == 1 then
        self.tiles[x][y] = Tile.new(Tile.rockTile)
      end
    end)
  else
    --roomsncorridors
    local gen = ROT.Map.Brogue:new(mapWidth,mapHeight)
    gen:create(function (x,y,val)
      if val == 0 then
        self.tiles[x][y] = Tile.new(Tile.floorTile)
      elseif val == 1 then
        self.tiles[x][y] = Tile.new(Tile.wallTile)
      end
    end)
  end

  --do bitmasking
  for x,row in pairs(self.tiles) do
    for y, tile in pairs(row) do
      local bitMask = 0
        -- north
      if self.getTile(x,y-1) and self.getTile(x,y-1).name == tile.name then bitMask = bitMask + 1 end
        -- east
      if self.getTile(x+1,y) and self.getTile(x+1,y).name == tile.name then bitMask = bitMask + 4 end
        --south
      if self.getTile(x,y+1) and self.getTile(x,y+1).name == tile.name then bitMask = bitMask + 8 end
        --west
      if self.getTile(x-1,y) and self.getTile(x-1,y).name == tile.name then bitMask = bitMask + 2 end

      self.tiles[x][y].bitMask = bitMask
    end
  end

  return self
end
