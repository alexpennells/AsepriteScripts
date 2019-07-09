-----------------------------------------------------------------------------------
-- Adds a new layer with a 1px border around each layer, respecting overlaps
-----------------------------------------------------------------------------------

function forEachPixel(sprite, frame, layer, dest, callback)
  local cel = layer:cel(frame)
  if cel == nil then return end

  local src = Image(sprite.width, sprite.height, sprite.colorMode)
  src:drawImage(cel.image, cel.position)

  for x = 0, sprite.width - 1, 1 do
    for y = 0, sprite.height - 1, 1 do
      callback(src, dest, x, y, src:getPixel(x, y))
    end
  end
end

function drawBorder(src, dest, x, y, pixel)
  if not isTransparent(pixel) then
    dest:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, 0))
    return
  end

  local draw = false
  if x > 0 and not isTransparent(src:getPixel(x - 1, y)) then draw = true end
  if y > 0 and not isTransparent(src:getPixel(x, y - 1)) then draw = true end
  if x < (src.width - 1) and not isTransparent(src:getPixel(x + 1, y)) then draw = true end
  if y < (src.height - 1) and not isTransparent(src:getPixel(x, y + 1)) then draw = true end
  if draw then dest:drawPixel(x, y, DEFAULTS.borderColor.rgbaPixel) end
end

function isTransparent(pixel)
  return app.pixelColor.rgbaA(pixel) == 0
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

DEFAULTS = dialog.data
if not DEFAULTS.ok then return 0 end

----------------------------------------------------------------------
-- BORDER TRANSACTION
----------------------------------------------------------------------

app.transaction(
  function()
    local border = sprite:newLayer()
    border.name = "Pebbz:LayerBorder"

    for i,frame in ipairs(sprite.frames) do
      cel = sprite:newCel(border, i)

      for k,layer in ipairs(sprite.layers) do
        if layer ~= border then
          forEachPixel(sprite, i, layer, cel.image, drawBorder)
        end
      end
    end
  end
)
