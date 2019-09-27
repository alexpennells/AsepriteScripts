----------------------------------------------------------------------
-- Adds a new layer with a 1px black border around the whole image
----------------------------------------------------------------------

function transparentOrMatch(pixel, color, useMatch)
  return app.pixelColor.rgbaA(pixel) == 0 or (useMatch and Color(pixel) == color)
end

function drawBorder(sprite, frame, color, useMatch)
  local copiedImage = Image(sprite.width, sprite.height, sprite.colorMode)
  local borderImage = Image(copiedImage)

  copiedImage:drawSprite(sprite, frame)
  for x = 0, sprite.width - 1, 1 do
    for y = 0, sprite.height - 1, 1 do
      if transparentOrMatch(copiedImage:getPixel(x, y), color) then
        local draw = false
        if x > 0 and not transparentOrMatch(copiedImage:getPixel(x - 1, y), color, useMatch) then draw = true end
        if y > 0 and not transparentOrMatch(copiedImage:getPixel(x, y - 1), color, useMatch) then draw = true end
        if x < (sprite.width - 1) and not transparentOrMatch(copiedImage:getPixel(x + 1, y), color, useMatch) then draw = true end
        if y < (sprite.height - 1) and not transparentOrMatch(copiedImage:getPixel(x, y + 1), color, useMatch) then draw = true end
        if draw then borderImage:drawPixel(x, y, color) end
      end
    end
  end

  return borderImage
end

function findOrCreateLayer(sprite, name)
  for k,layer in ipairs(sprite.layers) do
    if layer.name == name then return layer end
  end

  local newLayer = sprite:newLayer()
  newLayer.name = name
  return newLayer
end

----------------------------------------------------------------------
-- PRE-SCRIPT VALIDATIONS
----------------------------------------------------------------------

if app.apiVersion < 3 then return app.alert("ERROR: This script requires API version 3.") end

sprite = app.activeSprite
if sprite == nil then return app.alert("ERROR: Active Sprite does not exist.") end

----------------------------------------------------------------------
-- SHOW DIALOG
----------------------------------------------------------------------

local dialog = Dialog()
dialog:color({ id = "borderColor", label = "Border Color", color = Color{ r = 0, g = 0, b = 0, a = 255 } })
dialog:slider({ id = "thickness", label = "Thickness", min = "1", max = "10", value = "1" })
dialog:check({ id = "drawOver", label = "Draw over pixels that match", selected = false })
dialog:button({ id = "cancel", text = "Cancel" })
dialog:button({ id = "ok", text = "OK" })
dialog:show()

defaults = dialog.data
if not defaults.ok then return 0 end

----------------------------------------------------------------------
-- BORDER TRANSACTION
----------------------------------------------------------------------

app.transaction(
  function()
    for t = 0, defaults.thickness - 1, 1 do
      local layer = findOrCreateLayer(sprite, "Pebbz:ImageBorder")

      local frames = sprite.frames
      if app.range.type == RangeType.FRAMES then frames = app.range.frames end

      for i,frame in ipairs(frames) do
        sprite:newCel(layer, frame, drawBorder(sprite, i, defaults.borderColor, defaults.drawOver), Point())
      end

      if t > 0 then app.command.MergeDownLayer() end
    end
  end
)
