----------------------------------------------------------------------
-- Finds the layer in the sprite with the given name
-- or creates one at the top of the stack.
--
-- PARAMS
-- sprite (Sprite)
-- name (String)
--
-- RETURNS
-- Layer
----------------------------------------------------------------------

function findOrCreateLayer(sprite, name)
  local pebbzGroup = nil
  for k,layer in ipairs(sprite.layers) do
    if layer.name == '_pebbz_' and layer.isGroup then
      pebbzGroup = layer
    end
  end

  if pebbzGroup == nil then
    pebbzGroup = sprite:newGroup()
    pebbzGroup.name = '_pebbz_'
  end

  for k,layer in ipairs(pebbzGroup.layers) do
    if layer.name == name then return layer end
  end

  local newLayer = sprite:newLayer()
  newLayer.name = name
  newLayer.parent = pebbzGroup
  return newLayer
end
