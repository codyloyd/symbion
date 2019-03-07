particles = {}

function particles.new(x,y,l,s,c)
  local life = l and math.random() * l or math.random()
  local speed = s and math.random() * s or math.random() * 50
  local color = c or {1,1,1}
  table.insert(particles, {
      x=x,
      y=y,
      color=color,
      life=life,
      speed=speed,
      dx=randomD(),
      dy=randomD()
    })
end

function randomD()
  return math.random() * 2 - 1
end

function particles.update(dt)
  for i, particle in ipairs(particles) do
    particle.x = particle.x + particle.dx * dt * particle.speed 
    particle.y = particle.y + particle.dy * dt * particle.speed 
    particle.life = particle.life - dt
    if particle.life <= 0 then
      table.remove(particles, i)
    end
  end
end

function particles.draw()
  for _, particle in ipairs(particles) do
    love.graphics.setColor(particle.color)
    love.graphics.rectangle('fill', particle.x, particle.y, 4, 4)
  end
end
