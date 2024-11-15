local aggregate_chest_names = {
  ["ee-aggregate-chest"] = "ee-aggregate-chest",
  ["ee-aggregate-chest-passive-provider"] = "ee-aggregate-chest-passive-provider",
}

--- @type InfinityInventoryFilter[]
local function create_infinity_filters(entity)
  local filters = {}
  do
    local include_hidden = settings.global["ee-aggregate-include-hidden"].value
    local i = 0
    for name, prototype in pairs(prototypes.item) do
      if
        (include_hidden or not prototype.hidden)
        -- FIXME: Prevent items from spoiling
        and not prototype.spoil_result
        and not prototype.spoil_to_trigger_result
      then
        i = i + 1
        filters[i] = { name = name, quality = entity.quality.name, count = prototype.stack_size, mode = "exactly", index = i }
      end
    end
  end
  return filters
end
--- Set the filters for the given aggregate chest and removes the bar if there is one
--- @param entity LuaEntity
local function set_filters(entity)
  entity.remove_unfiltered_items = true
  entity.infinity_container_filters = create_infinity_filters(entity)
  entity.get_inventory(defines.inventory.chest).set_bar()
end

-- Update the filters of all existing aggregate chests
local function update_all_filters()
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ name = aggregate_chest_names })) do
      set_filters(entity)
    end
  end
end

--- @param e BuiltEvent
local function on_entity_built(e)
  local entity = e.entity or e.destination
  if not entity or not entity.valid or not aggregate_chest_names[entity.name] then
    return
  end
  set_filters(entity)
end

--- @param e EventData.on_player_setup_blueprint
local function on_player_setup_blueprint(e)
  local blueprint = e.stack
  if not blueprint then
    return
  end

  local entities = blueprint.get_blueprint_entities()
  if not entities then
    return
  end
  local set = false
  for _, entity in pairs(entities) do
    if aggregate_chest_names[entity.name] then
      set = true
      entity.infinity_settings.filters = nil --- @diagnostic disable-line
    end
  end
  if set then
    blueprint.set_blueprint_entities(entities)
  end
end

local aggregate_chest = {}

aggregate_chest.on_configuration_changed = function(_)
  update_all_filters()
end

aggregate_chest.events = {
  [defines.events.on_built_entity] = on_entity_built,
  [defines.events.on_entity_cloned] = on_entity_built,
  [defines.events.on_player_setup_blueprint] = on_player_setup_blueprint,
  [defines.events.on_robot_built_entity] = on_entity_built,
  [defines.events.script_raised_built] = on_entity_built,
  [defines.events.script_raised_revive] = on_entity_built,
}

return aggregate_chest
