dofile("./isTransparentPixel.lua")

----------------------------------------------------------------------
-- Creates a new image which contains an outline of the passed image.
--
-- PARAMS
-- image (Image)
-- color (Color)
--
-- RETURNS
-- Image
----------------------------------------------------------------------

function outlineImage(image, color)
  local outline = Image(image.width, image.height, image.colorMode)

  for x = 0, image.width - 1, 1 do
    for y = 0, image.height - 1, 1 do
      if isTransparentPixel(image:getPixel(x, y)) then
        local draw = false
        if x > 0 and not isTransparentPixel(image:getPixel(x - 1, y)) then draw = true end
        if y > 0 and not isTransparentPixel(image:getPixel(x, y - 1)) then draw = true end
        if x < (image.width - 1) and not isTransparentPixel(image:getPixel(x + 1, y)) then draw = true end
        if y < (image.height - 1) and not isTransparentPixel(image:getPixel(x, y + 1)) then draw = true end
        if draw then outline:drawPixel(x, y, color) end
      end
    end
  end

  return outline
end
