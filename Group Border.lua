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
    local border = findOrCreateLayer(sprite, "Group Border")

    local cel = sprite:newCel(border, frame.frameNumber)
    local outline = Image(sprite.width, sprite.height, sprite.colorMode)

    for k,layer in ipairs(sprite.layers) do
      if layer ~= border then
        if layer.isGroup then
          local groupImage = Image(sprite.width, sprite.height, sprite.colorMode)

          for j,sublayer in ipairs(layer.layers) do
            local sublayerCel = sublayer:cel(frame.frameNumber)
            if sublayerCel ~= nil then
              local celImage = Image(sprite.width, sprite.height, sprite.colorMode)
              celImage:drawImage(sublayerCel.image, sublayerCel.position)
              mergeImages(groupImage, celImage)
            end
          end

          removeImageOverlap(outline, groupImage)
          mergeImages(outline, outlineImage(groupImage, settings.borderColor))
        else
          local layerCel = layer:cel(frame.frameNumber)
          if layerCel ~= nil then
            local celImage = Image(sprite.width, sprite.height, sprite.colorMode)
            celImage:drawImage(layerCel.image, layerCel.position)

            removeImageOverlap(outline, celImage)
            mergeImages(outline, outlineImage(celImage, settings.borderColor))
          end
        end
      end
    end

    cel.image = outline
  end
)
