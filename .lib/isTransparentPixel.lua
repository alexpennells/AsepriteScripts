----------------------------------------------------------------------
-- Determines if a pixel is completely transparent
--
-- PARAMS
-- pixel (Integer)
--
-- RETURNS
-- Boolean
----------------------------------------------------------------------

function isTransparentPixel(pixel)
  return app.pixelColor.rgbaA(pixel) == 0
end
