Mixins = {}

-- Movable!
Mixins.Movable = {
  name = 'Movable'
}

function Mixins.Movable:tryMove(x,y,level)
    local tile = level.map.getTile(x,y)
    local target = level.getEntityAt(x,y)
    if player.x == x and player.y == y then
      target = player
    end
    if target and target:hasMixin('Destructible') then
      if self:hasMixin('Attacker') then
        self:attack(target)
      end
      return
    end
    if self:hasMixin('SymbionUser') and level.symbions[x..','..y] then
      enterSymbionSelectionScreen(level.symbions[x..','..y])
    end
    if tile and tile.isWalkable then
      self.x, self.y = x, y
      return true
    end
    return false
  end

-- Destructible!

Mixins.Destructible = {
  name = 'Destructible',
}

function Mixins.Destructible:init(opts)
  self.maxHp = opts and opts.maxHp or 10
  self.hp = opts and opts.hp or self.maxHp
  self.defenseValue = opts and opts.defenseValue or 0
  self.healthRegenRate = opts and opts.healthRegenRate or 0 
end

function Mixins.Destructible:updateHealth()
  self.hp = math.min(self.maxHp, self.hp + self.healthRegenRate)
  updateUi:trigger('healthBar', self.hp/self.maxHp)
end

function Mixins.Destructible:takeDamage(attacker, damage)
  self.hp = self.hp - damage
  self:hit()
  if self == player then
    startShake(.15,1)
    flashScreen(.04)
    updateUi:trigger('healthBar', self.hp/self.maxHp)
  end
  if self.hp <= 0 then
    if self == player then
      -- switch screen LOSERRRR
      switchScreen(loseScreen)
    else
      if self.deathCallback then
        self:deathCallback()
      end
      self.level.removeEntity(self)
    end
  end
end

-- Attacker!!

local Attacker = {
  name = 'Attacker',
  groupName = 'Attacker'
}

function Attacker:init(opts)
  self.attackValue = opts and opts.attackValue or 1
  self.attackModifier = 1
end

function Attacker:attack(target)
  if target == self then return end
  if target:hasMixin('Destructible') then
    local attack, defense = self.attackValue * self.attackModifier, target.defenseValue
    local damage = math.random(1, math.max(0, attack - defense))
    target:takeDamage(self, damage)
  end
end

Mixins.Attacker = Attacker


-- Sight !!
local Sight = {
  name = 'Sight'
}

function Sight:init(opts)
  self.sightRadius = opts and opts.sightRadius or 5
end

function Sight:canSee(entity)
  -- if they're on the same level
  if entity.map ~= self.map then return false end
  -- and technically within the SightRadius
  if math.abs(entity.x - self.x) > tonumber(self.sightRadius) or
  math.abs(entity.y - self.y) > tonumber(self.sightRadius) then
    return false
  end

  local found = false
  fov:compute(self.x, self.y, tonumber(self.sightRadius), function(x,y,r,v)
    if x == entity.x and y == entity.y then
      found = true
    end
  end)
  return found
end

Mixins.Sight = Sight

local InventoryHolder = {
  name = 'InventoryHolder'
}

function InventoryHolder:init(opts)
  self.inventory = {}
end

function InventoryHolder:addInventoryItem(item)
  table.insert(self.inventory, item)
end

Mixins.InventoryHolder = InventoryHolder

local SymbionUser = {
  name="SymbionUser"
}

function SymbionUser:init(opts)
  self.symbionLimit = opts and opts.symbionLimit or 5
  self.symbions = {}
  self.attachedSymbion = nil
end

function SymbionUser:addSymbion(sym)
  if #self.symbions < self.symbionLimit then
    table.insert(self.symbions, sym)
    return true
  end
  return false
end

function SymbionUser:updateSymbions()
  lume.each(self.symbions, function(sym)
    sym:update()
  end)
end

Mixins.SymbionUser = SymbionUser

-- Actors!!

Mixins.PlayerActor = {
  name= 'PlayerActor',
  groupName= 'Actor',
  act= function(self)
    if self:hasMixin('SymbionUser') then
      self:updateSymbions()
    end
    if self:hasMixin('Destructible') then
      self:updateHealth()
    end
    refresh()
    engine:lock()
  end
}

Mixins.FungusActor = {
  name= 'FungusActor',
  groupName= 'Actor',
}

function Mixins.FungusActor:init()
  self.growthsRemaining = 5;
end

function Mixins.FungusActor:act()
  if self.growthsRemaining > 0 then
    if math.random(10) < 3 then
      local xoffset, yoffset = math.random(-1, 1), math.random(-1, 1)
      if xoffset ~= 0 or yoffset ~= 0 then
        local x, y = self.x + xoffset, self.y + yoffset
        if self.level.isEmptyFloor(x, y) then
          local newFungus = Entity.new(Entity.templates.fungus)
          newFungus.x, newFungus.y = x, y
          self.level.addEntity(newFungus)
          self.growthsRemaining = self.growthsRemaining - 1
        end
      end
    end
  end
end

Mixins.MonsterActor = {
  name = 'MonsterActor',
  groupName = 'Actor'
}

function Mixins.MonsterActor:init()
  self.canStun = true
end

function Mixins.MonsterActor:act()
  if self.stunnedTime >= 0 then
    self.stunnedTime = self.stunnedTime - 1
    return
  end
  local dx = math.random( -1, 1 )
  local dy = math.random( -1, 1 )
  if self:canSee(player) then
    local newX, newY = nil, nil
    local path = ROT.Path.AStar(player.x, player.y, function(x,y)

      local entity = self.level.getEntityAt(x,y)
      if entity and entity ~= player and entity ~= self and entity.name ~= "playerProjectile" then
        return false
      end

      return self.map.getTile(x,y) and self.map.getTile(x,y).isWalkable

    end)

    local count = 0
    path:compute(self.x, self.y, function(x,y)
      if count == 1 then
        newX, newY = x, y
      end
      count = count + 1
    end)
    if newX and newY then
      self:tryMove(newX, newY, self.level)
      return
    end
  else
    if dx or dy then
      self:tryMove(self.x + dx, self.y + dy, self.level)
    end
  end
end

Mixins.PlantActor = {
  name='PlantActor',
  groupName='Actor'
}

function Mixins.PlantActor:act()
  local level = self.level
  for x=-1,1 do
    for y=-1,1 do
      if x == 0 and y == 0 then
      elseif math.random(10) < 5 then
        local newProjectile = Entity.new(Entity.templates.projectile) 
        newProjectile.direction = {x,y}
        newProjectile.x, newProjectile.y = self.x + newProjectile.direction[1], self.y + newProjectile.direction[2]
        level.addEntity(newProjectile)
      end
    end
  end
end


Mixins.ChelzrathActor = {
  name = 'ChelzrathActor',
  groupName = 'Actor'
}

function Mixins.ChelzrathActor:act()
  local level = self.level
  for x=-1,1 do
    for y=-1,1 do
      if x == 0 and y == 0 then
      else
        local newProjectile = Entity.new(Entity.templates.projectile) 
        if math.random(10) < 2 then
          newProjectile = Entity.new(Entity.templates.bomb) 
        end
        newProjectile.direction = {x,y}
        newProjectile.x, newProjectile.y = self.x + newProjectile.direction[1], self.y + newProjectile.direction[2]
        level.addEntity(newProjectile)
      end
    end
  end
end

function Mixins.ChelzrathActor:deathCallback()
  fadeOut(40, function() 
    endGame:trigger('win')
  end)
end

Mixins.playerProjectile = {
  name='playerProjectile'
}

Mixins.ProjectileActor = {
  name='ProjectileActor',
  groupName='Actor'
}

function Mixins.ProjectileActor:init(opts)
  self.direction = opts and opts.direction or {-1, 0}
end

function Mixins.ProjectileActor:act()
  local x, y, level = self.x + self.direction[1], self.y + self.direction[2], self.level
  local target
  local tile = level.map.getTile(x,y)
  if tile and tile.blocksLight or not tile then
    self.level.removeEntity(self)
    return true
  end
  if self:hasMixin('playerProjectile') then
    target = level.getEntityAt(x,y)
  else
    if player.x == x and player.y == y then
      target = player
    end
  end
  if target and target:hasMixin('Destructible') then
    target:takeDamage(self, 1)
    self.level.removeEntity(self)
    local topLeftX = math.max(1, player.x - (screenWidth / 2))
    local topLeftX = math.min(topLeftX, mapWidth - screenWidth)
    local topLeftY = math.max(1, player.y - (screenHeight / 2))
    local topLeftY = math.min(topLeftY, mapHeight - screenHeight)

    fireworks((self.x-topLeftX)*2*tilewidth+tilewidth,(self.y-topLeftY)*2*tileheight+tileheight, self.fg,100,3,15)
    return true
  end

  self.x, self.y = x, y

  if self:hasMixin('Exploder') then
    self:tick()
  end
  return true
end

Mixins.Exploder = {
  name='Exploder'
}

function Mixins.Exploder:init(opts)
  self.life = opts and opts.life or math.random(6)
end

function Mixins.Exploder:tick()
  local level = self.level
  self.life = self.life - 1
  if self.life == 0 then
    for x=-1,1 do
      for y=-1,1 do
        if x == 0 and y == 0 then
        else
          if math.random(10) > 5 then
            local newProjectile = Entity.new(Entity.templates.projectile) 
            newProjectile.direction = {x,y}
            newProjectile.x, newProjectile.y = self.x + newProjectile.direction[1], self.y + newProjectile.direction[2]
            level.addEntity(newProjectile)
          end
        end
      end
    end
    local topLeftX = math.max(1, player.x - (screenWidth / 2))
    local topLeftX = math.min(topLeftX, mapWidth - screenWidth)
    local topLeftY = math.max(1, player.y - (screenHeight / 2))
    local topLeftY = math.min(topLeftY, mapHeight - screenHeight)

    fireworks((self.x-topLeftX)*2*tilewidth+tilewidth,(self.y-topLeftY)*2*tileheight+tileheight, self.fg,400,2,25)
    self.level.removeEntity(self)
  end
end

Mixins.SymbionActor = {
  name="SymbionActor",
  groupName="Actor"
}

function Mixins.SymbionActor:deathCallback()
  local drop = Symbion.new(Symbion.randomSymbion())
  self.level.addSymbion(drop, self.x, self.y)
end

function Mixins.SymbionActor:act()
  if love.math.random(10) < 6 then
    local xoffset, yoffset = math.random(-1, 1), math.random(-1, 1)
    if xoffset ~= 0 or yoffset ~= 0 then
      local x, y = self.x + xoffset, self.y + yoffset
      if self.level.isEmptyFloor(x, y) then
        local newFungus = Entity.new(Entity.templates.fungus)
        if math.random(10) < 3 then
          newFungus = Entity.new(Entity.templates.plantguy)
        end
        newFungus.x, newFungus.y = x, y
        self.level.addEntity(newFungus)
      end
    end
  end
end

