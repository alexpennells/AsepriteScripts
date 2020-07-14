dofile("./isTransparentPixel.lua")

----------------------------------------------------------------------
-- Draws an image onto another image. Transparent pixels
-- will not be drawn in the resulting image
--
-- PARAMS
-- dest (Image)
-- src (Image)
--
-- RETURNS
-- None
----------------------------------------------------------------------

function mergeImages(dest, src)
  for x = 0, src.width - 1, 1 do
    for y = 0, src.height - 1, 1 do
      local curPixel = src:getPixel(x, y)
      if not isTransparentPixel(curPixel) then
        dest:drawPixel(x, y, curPixel)
      end
    end
  end
end
