math.randomseed(os.time())

if app.activeSprite == nil then
  return app.alert("ERROR: Active Sprite does not exist.")
end

local diffuseFilename = app.activeSprite.filename
if not string.match(diffuseFilename, "_Diffuse") then
  return app.alert("ERROR: Diffuse was not found in filename.")
end

----------------------------------------------------------------------
-- DEFAULTS
----------------------------------------------------------------------

local dialog = Dialog()
dialog:check({ id = "top", label = "top", selected = true })
dialog:check({ id = "bottom", label = "bottom", selected = true })
dialog:check({ id = "left", label = "left", selected = true })
dialog:check({ id = "right", label = "right", selected = true })
dialog:check({ id = "front", label = "front", selected = true })

dialog:slider({ id = "upper", label = "upper", min = "0", max = "255", value = "255" })
dialog:slider({ id = "lower", label = "lower", min = "0", max = "255", value = "100" })
dialog:slider({ id = "shadow", label = "shadow", min = "0", max = "255", value = "150" })
dialog:slider({ id = "decay", label = "decay", min = "1", max = "10", value = "2" })
dialog:slider({ id = "random", label = "random", min = "0", max = "100", value = "0" })

dialog:button({ id = "cancel", text = "Cancel" })
dialog:button({ id = "ok", text = "OK" })
dialog:show()

defaults = dialog.data
if not defaults.ok then return 0 end

----------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------

function getData(input, name, default)
  for k, v in string.gmatch(input, "(%w+)=(%w+)") do
    if k == name then
      return tonumber(v)
    end
  end
  return default
end

function adjust(sprite, lighten, darken)
  for i,layer in ipairs(sprite.layers) do
    local mods = {
      upper = getData(layer.data, "upper", defaults.upper),
      lower = getData(layer.data, "lower", defaults.lower),
      random = getData(layer.data, "random", defaults.random),
      shadow = getData(layer.data, "shadow", defaults.shadow),
      decay = getData(layer.data, "decay", defaults.decay)
    }
    mods.range = mods.upper - mods.lower

    for k,cel in ipairs(layer.cels) do
      -- Apply lighten per pixel to the image
      for x = 0, cel.bounds.width - 1, 1 do
        for y = 0, cel.bounds.height - 1, 1 do
          local pixel = cel.image:getPixel(x, y)

          local color = lighten({
            x = x / cel.bounds.width,
            y = y / cel.bounds.height
          }, mods) + math.random(0, mods.random * 2) - mods.random

          if color > mods.upper then color = mods.upper end
          if color < mods.lower then color = mods.lower end

          cel.image:drawPixel(x, y, app.pixelColor.rgba(
            color,
            color,
            color,
            app.pixelColor.rgbaA(pixel)
          ))
        end
      end

      darken(cel, mods)
    end
  end

  return sprite
end

----------------------------------------------------------------------
-- TOP
----------------------------------------------------------------------

if defaults.top then
  local sprite = adjust(
    app.open(diffuseFilename),
    function(t, mods)
      return mods.lower + math.cos(t.y * math.pi / 2) * mods.range
    end,
    function(cel, mods)
      local i = Image(cel.bounds.width, cel.bounds.height + mods.decay, cel.image.colorMode)
      i:drawImage(cel.image, 0, 0)
      cel.image = i

      for x = 0, cel.bounds.width - 1, 1 do
        local shade = 0
        for y = 0, cel.bounds.height - 1, 1 do
          if app.pixelColor.rgbaA(cel.image:getPixel(x, y)) ~= 255 then
            if shade > 0 then cel.image:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, shade)) end
            shade = shade - mods.shadow / mods.decay
          else
            shade = mods.shadow
          end
        end
      end
    end
  )

  sprite:saveAs(sprite.filename:gsub("_Diffuse", "_Top"))
end


----------------------------------------------------------------------
-- BOTTOM
----------------------------------------------------------------------

if defaults.bottom then
  sprite = adjust(
    app.open(diffuseFilename),
    function(t, mods)
      return mods.lower + math.sin(t.y * math.pi / 2) * mods.range
    end,
    function(cel, mods)
      local i = Image(cel.bounds.width, cel.bounds.height + mods.decay, cel.image.colorMode)
      i:drawImage(cel.image, 0, mods.decay)
      cel.image = i
      cel.position = Point(cel.position.x, cel.position.y - mods.decay)

      for x = 0, cel.bounds.width - 1, 1 do
        local shade = 0
        for y = cel.bounds.height - 1, 0, -1 do
          if app.pixelColor.rgbaA(cel.image:getPixel(x, y)) ~= 255 then
            if shade > 0 then cel.image:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, shade)) end
            shade = shade - mods.shadow / mods.decay
          else
            shade = mods.shadow
          end
        end
      end
    end
  )

  sprite:saveAs(sprite.filename:gsub("_Diffuse", "_Bottom"))
end

----------------------------------------------------------------------
-- LEFT
----------------------------------------------------------------------

if defaults.left then
  sprite = adjust(
    app.open(diffuseFilename),
    function(t, mods)
      return mods.lower + math.cos(t.x * math.pi / 2) * mods.range
    end,
    function(cel, mods)
      local i = Image(cel.bounds.width + mods.decay, cel.bounds.height, cel.image.colorMode)
      i:drawImage(cel.image, 0, 0)
      cel.image = i

      for y = 0, cel.bounds.height - 1, 1 do
        local shade = 0
        for x = 0, cel.bounds.width - 1, 1 do
          if app.pixelColor.rgbaA(cel.image:getPixel(x, y)) ~= 255 then
            if shade > 0 then cel.image:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, shade)) end
            shade = shade - mods.shadow / mods.decay
          else
            shade = mods.shadow
          end
        end
      end
    end
  )

  sprite:saveAs(sprite.filename:gsub("_Diffuse", "_Left"))
end

----------------------------------------------------------------------
-- RIGHT
----------------------------------------------------------------------

if defaults.right then
  sprite = adjust(
    app.open(diffuseFilename),
    function(t, mods)
      return mods.lower + math.sin(t.x * math.pi / 2) * mods.range
    end,
    function(cel, mods)
      local i = Image(cel.bounds.width + mods.decay, cel.bounds.height, cel.image.colorMode)
      i:drawImage(cel.image, mods.decay, 0)
      cel.image = i
      cel.position = Point(cel.position.x - mods.decay, cel.position.y)

      for y = 0, cel.bounds.height - 1, 1 do
        local shade = 0
        for x = cel.bounds.width - 1, 0, -1 do
          if app.pixelColor.rgbaA(cel.image:getPixel(x, y)) ~= 255 then
            if shade > 0 then cel.image:drawPixel(x, y, app.pixelColor.rgba(0, 0, 0, shade)) end
            shade = shade - mods.shadow / mods.decay
          else
            shade = mods.shadow
          end
        end
      end
    end
  )

  sprite:saveAs(sprite.filename:gsub("_Diffuse", "_Right"))
end

----------------------------------------------------------------------
-- FRONT
----------------------------------------------------------------------

if defaults.front then
  sprite = adjust(
    app.open(diffuseFilename),
    function(t, mods)
      return mods.lower + math.max(math.sin(t.x * math.pi), math.sin(t.y * math.pi)) * mods.range
    end,
    function(cel, mods)
    end
  )

  sprite:saveAs(sprite.filename:gsub("_Diffuse", "_Front"))
end
