dofile("./.lib/invokeScript.lua")
dofile("./.lib/findOrCreateLayer.lua")
dofile("./.lib/removeImageOverlap.lua")
dofile("./.lib/outlineImage.lua")
dofile("./.lib/mergeImages.lua")

invokeScript(
  function()
    local dialog = Dialog()
    dialog:color({ id = "borderColor", label = "Border Color", color = Color{ r = 0, g = 0, b = 0, a = 255 } })
    dialog:button({ id = "cancel", text = "Cancel" })
    dialog:button({ id = "ok", text = "OK" })
    dialog:show()

    return dialog.data
  end,

  function(sprite, frame, settings)
    local border = findOrCreateLayer(sprite, "Layer Border")

    local cel = sprite:newCel(border, frame.frameNumber)
    local outline = Image(sprite.width, sprite.height, sprite.colorMode)

    local drawCel = function (image, cel)
      if cel ~= nil then
        local celImage = Image(image.width, image.height, image.colorMode)
        celImage:drawImage(cel.image, cel.position)

        removeImageOverlap(image, celImage)
        mergeImages(image, outlineImage(celImage, settings.borderColor))
      end
    end

    for k,layer in ipairs(sprite.layers) do
      if layer ~= border then
        if layer.isGroup then
          for j,sublayer in ipairs(layer.layers) do
            drawCel(outline, sublayer:cel(frame.frameNumber))
          end
        else
          drawCel(outline, layer:cel(frame.frameNumber))
        end
      end
    end

    cel.image = outline
  end
)
