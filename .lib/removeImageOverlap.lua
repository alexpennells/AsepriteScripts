dofile("./isTransparentPixel.lua")

----------------------------------------------------------------------
-- Removes any non-transparent pixels that overlap
-- with the given image.
--
-- PARAMS
-- src (Image)
-- overlap (Image)
--
-- RETURNS
-- None
----------------------------------------------------------------------

function removeImageOverlap(src, overlap)
  for x = 0, overlap.width - 1, 1 do
    for y = 0, overlap.height - 1, 1 do
      local curPixel = overlap:getPixel(x, y)
      if not isTransparentPixel(curPixel) then
        src:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, 0))
      end
    end
  end
end
