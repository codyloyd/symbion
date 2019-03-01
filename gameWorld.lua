ROT=require './lib/rotLove/src/rot'
require('level')
require('entity')

GameWorld = {}
function GameWorld.new()
  local self = {}
  self.levels = {}
  self.currentLevel = 1
  self.levels[self.currentLevel] = Level.new({ mapStyle='forest' })

  function self:getCurrentLevel()
    return self.levels[self.currentLevel], self.currentLevel
  end

  function self:goDownLevel()
    if self.levels[self.currentLevel + 1] then

    else
      local levelStyle = 'dungeon'
      if (self.currentLevel > 2) then levelStyle = 'cave' end
      self.levels[self.currentLevel+1] = Level.new({mapStyle=levelStyle})
    end

    self.currentLevel = self.currentLevel + 1
    self.player.x, self.player.y = self:getCurrentLevel().upstairs.x, self:getCurrentLevel().upstairs.y
    self.player.map = self:getCurrentLevel().map
    return self.currentLevel
  end

  function self:goUpLevel()
    if self.currentLevel - 1 < 1 then
      return
    end

    self.currentLevel = self.currentLevel - 1
    self.player.x, self.player.y = self:getCurrentLevel().downstairs.x, self:getCurrentLevel().downstairs.y
    self.player.map = self:getCurrentLevel().map
    return self.currentLevel
  end

  --create player
  self.player = Entity.new(Entity.PlayerTemplate)
  self.player.x, self.player.y = self:getCurrentLevel().getRandomFloorPosition()
  self.player.map = self:getCurrentLevel().map
  scheduler:add(self.player, true)

  return self
end
