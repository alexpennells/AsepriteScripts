function invokeScript(settingsCallback, callback)
  if app.apiVersion < 3 then
    return app.alert("ERROR: This script requires API version 3.")
  end

  local sprite = app.activeSprite
  if sprite == nil then
    return app.alert("ERROR: Active Sprite does not exist.")
  end

  if app.range.type ~= RangeType.FRAMES then
    return app.alert("ERROR: No frames selected.")
  end

  local settings = settingsCallback()
  if not settings.ok then return 0 end

  app.transaction(
    function()
      for i,frame in ipairs(app.range.frames) do
        callback(sprite, frame, settings)
      end
    end
  )
end
