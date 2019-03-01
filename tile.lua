require('glyph')
require('colors')

Tile = {}
Tile.new = function(opts)
  local self = {}
  local glyph = Glyph.new(opts)
  for k,v in pairs(glyph) do
    self[k] = v
  end
  self.name = opts and opts.name or 'tile'
  self.blocksLight = opts and opts.blocksLight
  self.isWalkable = opts and opts.isWalkable
  return self
end

Tile.wallTile = {
  name='wallTile',
  char='#',
  tileset='Terrain',
  tileid=48,
  bitMaskMap = {
    [0]=48,
    [1]=48,
    [2]=48,
    [3]=48,
    [4]=48,
    [5]=48,
    [6]=48,
    [7]=48,
    [8]= 96,
    [9]= 96,
    [10]=96,
    [11]=96,
    [12]=96,
    [13]=96,
    [14]=96,
    [15]=96
  },
  fg=Colors.lightGray,
  blocksLight=true
}

Tile.rockTile = {
  name='rockTile',
  char='#',
  tileset='Terrain',
  tileid=120,
  bitMaskMap = {
    [0]=126,
    [1]=109,
    [2]=125,
    [3]={120,120,120,120,120,120,120,120,121,122},
    [4]=124,
    [5]={120,120,120,120,120,120,120,120,121,122},
    [6]={120,120,120,120,120,120,120,120,121,122},
    [7]={120,120,120,120,120,120,120,120,121,122},
    [8]= {96,96,96,96,96,96,97,99},
    [9]= {96,96,96,96,96,96,97,99},
    [10]={96,96,96,96,96,96,97,99},
    [11]={96,96,96,96,96,96,97,99},
    [12]={96,96,96,96,96,96,97,99},
    [13]={96,96,96,96,96,96,97,99},
    [14]={96,96,96,96,96,96,97,99},
    [15]={96,96,96,96,96,96,97,99}
  },
  fg=Colors.darkBrown,
  varyColor = 4,
  blocksLight=true
}

Tile.treeTile = {
  name='treeTile',
  char='#',
  tileset='Terrain_Objects',
  tileid={124,125,126},
  bitMaskMap = {
    [0]= {124,124,124,125,126},
    [1]= {124,124,124,125,126},
    [2]= {124,124,124,125,126},
    [3]= {124,124,124,125,126},
    [4]= {124,124,124,125,126},
    [5]= {124,124,124,125,126},
    [6]= {124,124,124,125,126},
    [7]= {124,124,124,125,126},
    [8]= {124,124,124,125,126},
    [9]= {124,124,124,125,126},
    [10]={124,124,124,125,126},
    [11]={124,124,124,125,126},
    [12]={124,124,124,125,126},
    [13]={124,124,124,125,126},
    [14]={124,124,124,125,126},
    [15]={124,124,124,125,126}
  },
  fg=Colors.lightGray,
  varyColor = 10,
  blocksLight=true
}

Tile.floorTile = {
  name='floorTile',
  char='.',
  tileset='Terrain_Objects',
  tileid=8,
  fg=Colors.darkGray,
  isWalkable=true
}

Tile.stairUpTile = {
    name='stairUpTile',
    char='<',
    tileset='Terrain',
    tileid=28,
    fg=Colors.white,
    isWalkable=true
}

Tile.stairDownTile = {
    name='stairDownTile',
    char='>',
    tileset='Terrain',
    tileid=29,
    fg=Colors.white,
    isWalkable=true
}

Tile.nullTile = Tile.new()
