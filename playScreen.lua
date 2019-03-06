require('map')
require('gameWorld')
require('tile')
require('entity')
require('symbion')
require('colors')
local grid = require('lib/grid')

local screen = {}
local subscreen
local confirmation
local alert
local targetingMode
player = nil

screen.enter = function()
  scheduler=ROT.Scheduler.Speed:new()
  engine=ROT.Engine:new(scheduler)
  engine:start()

  gameWorld = GameWorld.new()
  player = gameWorld.player
  local sym = Symbion.new(Symbion.templates.kill)
  player:addSymbion(sym)
  sym = Symbion.new(Symbion.randomSymbion())
  player:addSymbion(sym)
  sym = Symbion.new(Symbion.randomSymbion())
  player:addSymbion(sym)


  -- set up game UI elements
  uiElements = {}
  uiElements.healthBar = gooi.newBar({value=1}):bg(Colors.black):fg(Colors.white)
  uiElements.symbionLabel = gooi.newLabel({text='Symbion'}):left():fg(Colors.white)
  uiElements.symbionBar = gooi.newBar({value=1}):bg(Colors.black):fg(Colors.white)

  topLeft = gooi.newPanel({x=0,y=0,w = 300, h = 60, layout="grid 3x3"})
  topLeft
  :setColspan(1,2,2)
  :setColspan(2,2,2)
  :setColspan(3,2,2)
  :add(
      gooi.newLabel({text='Health'}):left():fg(Colors.white),
      uiElements.healthBar,
      uiElements.symbionLabel,
      uiElements.symbionBar
  ):setGroup('ui')
  uiElements.symbionBar:setVisible(false)
  uiElements.symbionLabel:setVisible(false)

  -- event for updating the UI
  updateUi = Luvent.newEvent()
  updateUi:addAction(
    function(uiElement, payload)
      if uiElements[uiElement] then
        uiElements[uiElement].value = payload
      end
      if uiElement == 'healthBar' and payload < .6 then
        uiElements[uiElement]:fg(Colors.red)
      end
      if uiElement == 'symbionGui' and payload == 'show' then
        uiElements.symbionBar.value = player.attachedSymbion.life/player.attachedSymbion.maxLife
        uiElements.symbionBar:setVisible(true)
        uiElements.symbionLabel:setVisible(true)
      end
      if uiElement == 'symbionGui' and payload == 'hide' then
        uiElements.symbionBar:setVisible(false)
        uiElements.symbionLabel:setVisible(false)
      end
      if uiElement == 'symbionName' then
        uiElements.symbionLabel:setText(payload)
      end
    end
  )

  endGame = Luvent.newEvent()
  endGame:addAction(function(winOrLose)
    if winOrLose == 'win' then
      switchScreen(winScreen)
    elseif winOrLose == 'lose' then
      switchScreen(loseScreen)
    end
  end)

end

screen.exit = function()
  engine:lock()
  uiElements = nil
  topLeft = nil
  gooi.components = {}
  gameWorld = {}
end

screen.update = function(dt)
  for _, entity in pairs(gameWorld:getCurrentLevel().entities) do
    if entity.hitTime < entity.hitDuration then
      entity.hitTime = entity.hitTime + dt
    end
  end
end

screen.render = function()
  love.graphics.setCanvas(mapCanvas)
  love.graphics.clear(Colors.black)
  local level = gameWorld:getCurrentLevel()
  local map = gameWorld:getCurrentLevel().map

  --generate FOV data
  local visibleTiles = {}
  local exploredTiles = level.exploredTiles

  fov = ROT.FOV.Precise:new(function(fov,x,y)
    if map.getTile(x,y) and map.getTile(x,y).blocksLight then
      return false
    end
    return true
  end)

  fov:compute(player.x, player.y, 10, function(x,y,r,v)
    local key  =x..','..y
    visibleTiles[key] = true
    exploredTiles[key] = true
  end)

  -- render map
  -- get bounds of our visible map by centering on the player
  local topLeftX = math.max(1, player.x - (screenWidth / 2))
  local topLeftX = math.min(topLeftX, mapWidth - screenWidth)
  local topLeftY = math.max(1, player.y - (screenHeight / 2))
  local topLeftY = math.min(topLeftY, mapHeight - screenHeight)

  -- only render things that are actually on the screen
  for x=topLeftX, topLeftX - 1 + screenWidth do
    for y=topLeftY, topLeftY - 1 + screenHeight do
      local tile = map.getTile(x,y)
      local key = x..','..y
      -- only render things if the FOV system says they're visible
      if visibleTiles[key] and tile then
        if tile then
          local id = tile.tileid
          if tile.bitMaskMap and tile.bitMask then
            id = tile.bitMaskMap[tile.bitMask]
          end

          local image = tiles[tile.tileset].image
          local quad = tiles[tile.tileset].tiles[id]
          if not tile.isLayering and x == player.x and y == player.y or level.items[x..','..y] or not tile.isLayering and level.getEntityAt(x,y) then
            -- if there's an item or the player on this tile, don't draw it
            -- unless it is set as a 'layering' tile
          else
            if tile.bg then
              if tile.flicker then
                love.graphics.setColor(Colors.vary(tile.bg, 8))
              else
                love.graphics.setColor(tile.bg)
              end
              love.graphics.rectangle('fill',(x-(topLeftX))*tilewidth,(y-(topLeftY))*tileheight, tilewidth, tileheight)
            end
              if tile.flicker then
                love.graphics.setColor(Colors.vary(tile.fg, 8))
              else
                love.graphics.setColor(tile.fg)
              end
            love.graphics.draw(image, quad, (x-(topLeftX))*tilewidth,(y-(topLeftY))*tileheight)
          end
        end
      -- render map tiles that have been explored already
      elseif exploredTiles[key] then
        local id = tile.tileid
        if tile.bitMaskMap and tile.bitMask then
          id = tile.bitMaskMap[tile.bitMask]
        end

        local image = tiles[tile.tileset].image
        local quad = tiles[tile.tileset].tiles[id]
        love.graphics.setColor(Colors.lightBlack)
        love.graphics.draw(image, quad, (x-(topLeftX))*tilewidth,(y-(topLeftY))*tileheight)
      end
    end
  end
  -- render dropped symbions
  for coords, symbion in pairs(level.symbions) do
    x,y = tonumber(splitString(coords, ',')[1]), tonumber(splitString(coords, ',')[2])
    if x >= topLeftX and y >= topLeftY and x < topLeftX + screenWidth and y < topLeftY + screenHeight then
      local key = coords
      if visibleTiles[key] then
        local image = tiles[symbion.tileset].image
        local quad = tiles[symbion.tileset].tiles[tonumber(symbion.tileid)]
        love.graphics.setColor(symbion.fg)
        love.graphics.draw(image,quad,(x-(topLeftX))*tilewidth, (y-(topLeftY))*tileheight)
      end
    end
  end

  --render items
  for coords, item in pairs(level.items) do
    x,y = tonumber(splitString(coords, ',')[1]), tonumber(splitString(coords, ',')[2])
    if x >= topLeftX and y >= topLeftY and x < topLeftX + screenWidth and y < topLeftY + screenHeight then
      local key = coords
      if visibleTiles[key] then
        local image = tiles[item.tileset].image
        local quad = tiles[item.tileset].tiles[tonumber(item.tileid)]
        love.graphics.setColor(item.fg)
        love.graphics.draw(image,quad,(x-(topLeftX))*tilewidth, (y-(topLeftY))*tileheight)
      end
    end
  end

  -- render entities
  for _, entity in pairs(level.entities) do
    if entity.x >= topLeftX and entity.y >= topLeftY and entity.x < topLeftX + screenWidth and entity.y < topLeftY + screenHeight then
      local key = entity.x..','..entity.y
      if visibleTiles[key] then
        local image = tiles[entity.tileset].image
        local quad = tiles[entity.tileset].tiles[tonumber(entity.tileid)]
        local dx,dy = 0, 0
        local r = entity:getAngle() or 0
        love.graphics.setColor(entity.fg)
        if entity.stunnedTime > 0 then
          dx,dy = math.random(0,1), math.random(0,1)
          love.graphics.setColor(Colors.vary(Colors.darkGray, 18))
        end
        if entity.hitTime < entity.hitDuration then
          dx,dy = math.random(-2,2), math.random(-2,2)
          love.graphics.setColor(Colors.addAlpha(Colors.red, .7))
          love.graphics.draw(image, quad, dx+(entity.x-(topLeftX))*tilewidth,dy+(entity.y-(topLeftY))*tileheight,r,1.2,1.2)
          dx,dy = math.random(-2,2), math.random(-2,2)
          love.graphics.setColor(1,0,0)
        end
        love.graphics.draw(image, quad, dx+(entity.x-(topLeftX))*tilewidth+tilewidth/2,dy+(entity.y-(topLeftY))*tileheight+tileheight/2,r,1,1,tilewidth/2,tileheight/2)

        local health = entity.hp/entity.maxHp
        if health < 1 then
          love.graphics.setColor(Colors.white)
          if health < .3 then
            love.graphics.setColor(Colors.red)
          end
          love.graphics.rectangle('fill', (entity.x-topLeftX)*tilewidth, tileheight+(entity.y-topLeftY)*tileheight,tilewidth*health, 2)
        end
      end
    end
  end

  -- render player
  love.graphics.setColor(Colors.pureWhite)
  love.graphics.print('@', 4+(player.x-(topLeftX))*tilewidth, (player.y-(topLeftY))*tileheight, 0, 1.5)

  --render targeting mode
  if targetingMode then
    local image = tiles[targeting.tileset].image
    local quad = tiles[targeting.tileset].tiles[tonumber(targeting.tileid)]
    love.graphics.setColor(Colors.pureWhite)
    love.graphics.draw(image, quad, (targeting.x-topLeftX)*tilewidth, (targeting.y-topLeftY)*tileheight)
  end


  -- render symbion buttons
  if not subscreen then
    for i,sym in ipairs(player.symbions) do
      local life = sym.life/sym.maxLife
      if player.attachedSymbion == sym then
        love.graphics.setColor(sym.fg)
        love.graphics.rectangle('fill',4, i*30,26,26)
        love.graphics.setColor(Colors.white)
        love.graphics.rectangle('line',4, i*30,25,26)
        local image = tiles[sym.tileset].image
        local quad = tiles[sym.tileset].tiles[tonumber(sym.tileid)]
        love.graphics.setColor(Colors.black)
        love.graphics.draw(image,quad,8,i*30)
      else
        love.graphics.setColor(Colors.addAlpha(Colors.black, .8))
        love.graphics.rectangle('fill',5, i*30,25,25)
        love.graphics.setColor(Colors.white)
        love.graphics.rectangle('line',4, i*30,26,26)
        local image = tiles[sym.tileset].image
        local quad = tiles[sym.tileset].tiles[tonumber(sym.tileid)]
        love.graphics.setColor(sym.fg)
        love.graphics.draw(image,quad,8,i*30)
      end

      if life < .4 then
        love.graphics.setColor(Colors.red)
      else
        love.graphics.setColor(Colors.white)
      end
      love.graphics.rectangle('fill',5,(i*30)+23,life*24,2)
    end
  end

love.graphics.setCanvas()

  function getHealthColor(hp, maxHp)
    percentage = hp/maxHp
    if percentage > .6 then
      return Colors.white
    else
      return Colors.red
    end
  end


  love.graphics.setColor(Colors.pureWhite)
  -- effects(function()
    love.graphics.draw(mapCanvas, 0,0,0,2)
  -- end)

  -- if there is a subscreen, do not draw UI stuff
  if subscreen then
    love.graphics.setColor(Colors.pureWhite)
    subscreen:render()
  else
    gooi.draw('ui')
  end

end


screen.keypressed = function(key)
  --confirmation dialog hijacks keypress functions
  if alert then
    gooi.closeDialog()
    alert = false
    return
  end
  if confirmation then
    if key =='escape' then
      gooi.closeDialog()
      confirmation = false
    end
    return
  end
  -- targetingmode
  if targetingMode then
    targeting.keypressed(key)
    return
  end
  --render subscreen keypress highjacks keypress function
  if subscreen then
    subscreen.keypressed(key)
    if key=='escape' then
      subscreen = nil
      refresh()
    end
    return
  end

  if key=='q'then
    fireworks(100,100)
  end

  if lume.any({'1','2','3'}, function(x) return key == x end) then
    if not player.attachedSymbion then
      if player.symbions[tonumber(key)] and player.symbions[tonumber(key)]:apply(player) then
        updateUi:trigger('symbionName', player.attachedSymbion.name)
        updateUi:trigger('symbionGui', 'show')
      end
    else
      local attached = lume.find(player.symbions, player.attachedSymbion)
      player.symbions[attached]:remove(player)
      updateUi:trigger('symbionGui', 'hide')
    end
  end

  if key=='return' then 
    switchScreen(winScreen)
  elseif key=='escape' then
    switchScreen(loseScreen)
  elseif key=='up' or key=='k' then
    move(0,-1)
  elseif key=='down' or key=='j' then
    move(0,1)
  elseif key=='left' or key =='h' then
    move(-1,0)
  elseif key=='right' or key== 'l' then
    move(1,0)
  elseif key=='b' then
    move(-1,1)
  elseif key=='n' then
    move(1,1)
  elseif key=='y' then
    move(-1,-1)
  elseif key=='u' then
    move(1,-1)
  elseif key=='.' and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")) then
    downstairs = gameWorld:getCurrentLevel().downstairs
    if player.x == downstairs.x and player.y == downstairs.y then
      gameWorld:goDownLevel()
      refresh()
    end
  elseif key==',' and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")) then
    upstairs = gameWorld:getCurrentLevel().upstairs
    if player.x == upstairs.x and player.y == upstairs.y then
      gameWorld:goUpLevel()
      refresh()
    end
  elseif key == '.' then
    engine:unlock()
  elseif key=='a' then
    if player.attachedSymbion and player.attachedSymbion.ability then
      player.attachedSymbion:ability(player)
      engine:unlock()
    end
  elseif key=='g' then
    -- pick item up
    -- local item = gameWorld:getCurrentLevel().items[player.x..','..player.y]
    -- if item then
    --   player:addInventoryItem(item)
    --   gameWorld:getCurrentLevel().removeItem(item)
    -- end
  elseif key=='i' then
    -- render item list screen
    -- subscreen = {}
    -- local myGrid = grid({
    --     x=0,
    --     y=0,
    --     w=love.graphics.getWidth(),
    --     h=love.graphics.getHeight(),
    --     rows=1,
    --     cols=8,
    --     margin = 8
    -- })
    -- local selectedItem = 0
    -- local listPane = myGrid.createCell({row=0, col=0, colSpan=2, padding=12})
    -- local listGrid = grid({x=listPane.x,y=listPane.y,h=listPane.h,w=listPane.w,rows=26})
    -- local listItem = listGrid.createCell({padding=12})
    -- local detailsPane = myGrid.createCell({row=0, col=2, colSpan=6, padding=12})
    -- function subscreen.render()
    --   love.graphics.setLineWidth(2)
    --   love.graphics.setColor(Colors.white)
    --   -- love.graphics.rectangle('line', listPane.getBorderBox())
    --   -- love.graphics.rectangle('line', detailsPane.getBorderBox())
    --   local fontHeight = love.graphics.getFont():getHeight()

    --   if #player.inventory == 0 then
    --     local x,y,w,h = listItem.getBorderBox()
    --     love.graphics.setColor(Colors.addAlpha(Colors.black, .8))
    --     love.graphics.rectangle("fill", x, y  + (h), w, h)
    --     local xx,yy,ww,hh = listItem.getContentBox()
    --     love.graphics.setColor(Colors.white)
    --     love.graphics.rectangle("line", x, y  + (h), w, h)
    --     love.graphics.setColor(Colors.white)
    --     love.graphics.printf("no items", xx, y + (h) + (h/2 - fontHeight/2),ww)
    --   end
    --   for i,item in ipairs(player.inventory) do
    --     local x,y,w,h = listItem.getBorderBox()
    --     love.graphics.setColor(Colors.addAlpha(Colors.black, .8))
    --     love.graphics.rectangle("fill", x, y  + (h*(i-1)), w, h)

    --     love.graphics.setColor(Colors.white)
    --     love.graphics.rectangle("line", x, y  + (h*(i-1)), w, h)
    --     if selectedItem + 1 == i then
    --       love.graphics.rectangle("fill", x, y  + (h*(i-1)), w, h)
    --       love.graphics.setColor(Colors.black)
    --     end
    --     local xx,yy,ww,hh = listItem.getContentBox()
    --     love.graphics.printf(item.name, xx, y + (h*(i-1)) + (h/2 - fontHeight/2),ww)
    --   end
    -- end

    -- function subscreen.keypressed(key)
    --   if key == 'j' or key == 'down' then
    --     selectedItem = (selectedItem + 1) % #player.inventory
    --   end
    --   if key == 'k' or key == 'up' then
    --     selectedItem = (selectedItem - 1) % #player.inventory
    --   end
    --   if key == 'return' then
    --     local item = player.inventory[selectedItem + 1]
    --     if item.apply then
    --       item:apply()
    --     end
    --     table.remove(player.inventory, selectedItem+1)
    --   end
    -- end
  elseif key=='s'then
    subscreen = {}
    local myGrid = grid({
        x=0,
        y=0,
        w=love.graphics.getWidth(),
        h=love.graphics.getHeight(),
        rows=1,
        cols=8,
        margin = 8
    })
    local selectedItem = 0
    local listPane = myGrid.createCell({row=0, col=0, colSpan=2, padding=12})
    local listGrid = grid({x=listPane.x,y=listPane.y,h=listPane.h,w=listPane.w,rows=26})
    local listItem = listGrid.createCell({padding=12})
    local detailsPane = myGrid.createCell({row=0, col=2, colSpan=6, padding=12})
    function subscreen.render()
      love.graphics.setLineWidth(2)
      love.graphics.setColor(Colors.white)
      -- love.graphics.rectangle('line', listPane.getBorderBox())
      -- love.graphics.rectangle('line', detailsPane.getBorderBox())
      local fontHeight = love.graphics.getFont():getHeight()

      if #player.symbions == 0 then
        local x,y,w,h = listItem.getBorderBox()
        love.graphics.setColor(Colors.addAlpha(Colors.black, .8))
        love.graphics.rectangle("fill", x, y  + (h), w, h)
        local xx,yy,ww,hh = listItem.getContentBox()
        love.graphics.setColor(Colors.white)
        love.graphics.rectangle("line", x, y  + (h), w, h)
        love.graphics.setColor(Colors.white)
        love.graphics.printf("no items", xx, y + (h) + (h/2 - fontHeight/2),ww)
      end
      for i,item in ipairs(player.symbions) do
        local x,y,w,h = listItem.getBorderBox()
        love.graphics.setColor(Colors.addAlpha(Colors.black, .8))
        love.graphics.rectangle("fill", x, y  + (h*(i-1)), w, h)

        love.graphics.setColor(Colors.white)
        love.graphics.rectangle("line", x, y  + (h*(i-1)), w, h)
        if selectedItem + 1 == i then
          love.graphics.rectangle("fill", x, y  + (h*(i-1)), w, h)
          love.graphics.setColor(Colors.black)
        end
        local xx,yy,ww,hh = listItem.getContentBox()
        love.graphics.printf(item.name, xx, y + (h*(i-1)) + (h/2 - fontHeight/2),ww)
      end
      local x,y,w,h = detailsPane.getContentBox()
      love.graphics.setColor(Colors.white)
      love.graphics.printf(player.symbions[selectedItem+1].desc, x,y,w,'left')
    end

    function subscreen.keypressed(key)
      if key == 'j' or key == 'down' then
        selectedItem = (selectedItem + 1) % #player.symbions
      end
      if key == 'k' or key == 'up' then
        selectedItem = (selectedItem - 1) % #player.symbions
      end
      if key == 'x' then
        local subscreenTemp = subscreen
        subscreen = nil
        confirmation = true
        gooi.confirm({
            text = "really remove "..player.symbions[selectedItem+1].name.."?\nThis action will kill him!",
            ok = function()
              player.symbions[selectedItem+1].kill()
              confirmation = false
            end,
            cancel=function()
              subscreen=subscreenTemp
              confirmation = false
            end
          })
      end
      if key == 'return' then
        if player.attachedSymbion then
          local attached = lume.find(player.symbions, player.attachedSymbion)
          player.symbions[attached]:remove(player)
        end
        if not player.attachedSymbion then
          if player.symbions[selectedItem + 1] and player.symbions[selectedItem + 1]:apply(player) then
            updateUi:trigger('symbionName', player.attachedSymbion.name)
            updateUi:trigger('symbionGui', 'show')
            subscreen = nil
          end
        end
      end
    end
  end
end

function move(dx, dy)
  newX = math.max(1, math.min(mapWidth, player.x + dx))
  newY = math.max(1, math.min(mapWidth, player.y + dy))
  player:tryMove(newX, newY, gameWorld:getCurrentLevel())
  engine:unlock()
end

function targetSomething(range, callback)
  targetingMode = true
  targeting.x, targeting.y = player.x, player.y
  if callback then
    targeting.callback = callback
  end
end

-- targeting mode
targeting = {}
targeting.tileset = "Interface"
targeting.tileid = 6
targeting.x = 0
targeting.y = 0
targeting.callback = function()end

function targeting.keypressed(key)
  local move = function(dx,dy)
    newX = math.max(1, math.min(mapWidth, targeting.x + dx))
    newY = math.max(1, math.min(mapWidth, targeting.y + dy))
    targeting.x, targeting.y = newX, newY 
  end
  if key=='escape' then
    targetingMode = false
  elseif key=='return' then
    targeting.callback(targeting.x, targeting.y)
    targetingMode = false
  elseif key=='up' or key=='k' then
    move(0,-1)
  elseif key=='down' or key=='j' then
    move(0,1)
  elseif key=='left' or key =='h' then
    move(-1,0)
  elseif key=='right' or key== 'l' then
    move(1,0)
  elseif key=='b' then
    move(-1,1)
  elseif key=='n' then
    move(1,1)
  elseif key=='y' then
    move(-1,-1)
  elseif key=='u' then
    move(1,-1)
  end
end

function enterSymbionSelectionScreen(symbion)
  if #player.symbions >= player.symbionLimit then
    gooi.alert({text="you are already carrying\nyour maximum number of symbions"})
    alert=true
    return
  end
    subscreen = {}
    function subscreen.render()
      love.graphics.setColor(Colors.black)
      love.graphics.rectangle('fill', 96, 96, 408, 408)
      love.graphics.setColor(Colors.white)
      love.graphics.printf(symbion.name, 100, 100, 400, 'left')
      love.graphics.printf(symbion.desc, 100, 124, 400, 'left')

      love.graphics.printf('press ENTER to pick up '..symbion.name..' press ESC to cancel', 100, 380, 400, 'left')
    end

    function subscreen.keypressed(key)
      if key=='return' then
        if player:addSymbion(symbion) then
          local level = gameWorld:getCurrentLevel()
          level.removeSymbion(symbion)
          subscreen = nil
        end
      end
    end
end

return screen
