math.randomseed(os.time())

if app.activeSprite == nil then
  return app.alert("ERROR: Active Sprite does not exist.")
end

for i, tag in ipairs(app.activeSprite.tags) do
  frame = tag.fromFrame
  while frame ~= nil and frame.frameNumber <= tag.toFrame.frameNumber do
    local image = Image(app.activeSprite.width, app.activeSprite.height)
    image:drawSprite(app.activeSprite, frame.frameNumber)
    image:saveAs(
      app.activeSprite.filename:gsub(
        "[^\\]*$",
        tag.name .. "_" .. (frame.frameNumber - tag.fromFrame.frameNumber) .. ".png")
    )
    frame = frame.next
  end
end
