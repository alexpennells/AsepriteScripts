----------------------------------------------------------------------
-- Adds a new layer with a 1px black border around the whole image
----------------------------------------------------------------------

function transparentOrMatch(pixel, color)
  return app.pixelColor.rgbaA(pixel) == 0 or Color(pixel) == color
end

function drawBorder(sprite, frame, color)
  local copiedImage = Image(sprite.width, sprite.height, sprite.colorMode)
  local borderImage = Image(copiedImage)

  copiedImage:drawSprite(sprite, frame)
  for x = 0, sprite.width - 1, 1 do
    for y = 0, sprite.height - 1, 1 do
      if transparentOrMatch(copiedImage:getPixel(x, y), color) then
        local draw = false
        if x > 0 and not transparentOrMatch(copiedImage:getPixel(x - 1, y), color) then draw = true end
        if y > 0 and not transparentOrMatch(copiedImage:getPixel(x, y - 1), color) then draw = true end
        if x < (sprite.width - 1) and not transparentOrMatch(copiedImage:getPixel(x + 1, y), color) then draw = true end
        if y < (sprite.height - 1) and not transparentOrMatch(copiedImage:getPixel(x, y + 1), color) then draw = true end
        if draw then borderImage:drawPixel(x, y, color) end
      end
    end
  end

  return borderImage
end

----------------------------------------------------------------------
-- PRE-SCRIPT VALIDATIONS
----------------------------------------------------------------------

if app.apiVersion ~= 3 then return app.alert("ERROR: This script requires API version 3.") end

sprite = app.activeSprite
if sprite == nil then return app.alert("ERROR: Active Sprite does not exist.") end

----------------------------------------------------------------------
-- SHOW DIALOG
----------------------------------------------------------------------

local dialog = Dialog()
dialog:color({ id = "borderColor", label = "Border Color", color = Color{ r = 0, g = 0, b = 0, a = 255 } })
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
    local layer = sprite:newLayer()
    layer.name = "Border"

    for i,frame in ipairs(sprite.frames) do
      sprite:newCel(layer, frame, drawBorder(sprite, i, defaults.borderColor), Point())
    end
  end
)
