dofile("./.lib/invokeScript.lua")
dofile("./.lib/findOrCreateLayer.lua")
dofile("./.lib/outlineImage.lua")

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
    local border = findOrCreateLayer(sprite, "Image Border")

    local cel = sprite:newCel(border, frame.frameNumber)
    local rawImage = Image(sprite.width, sprite.height, sprite.colorMode)

    rawImage:drawSprite(sprite, frame.frameNumber)
    cel.image = outlineImage(rawImage, settings.borderColor)
  end
)
