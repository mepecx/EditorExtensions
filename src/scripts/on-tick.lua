local on_tick = {}

local event = require("__flib__.event")

local infinity_wagon = require("scripts.entity.infinity-wagon")

function on_tick.handler()
  if next(global.wagons) then
    infinity_wagon.on_tick()
  else
    event.on_tick(nil)
  end
end

function on_tick.update()
  if next(global.wagons) then
    event.on_tick(on_tick.handler)
  else
    event.on_tick(nil)
  end
end

return on_tick