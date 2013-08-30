imageCanvas = null
context = null
canvasElement = null
width = null
height = null
svg = null
thickness = 40

getSample = (context, x, y) ->
  # TODO anti aliasing
  return context.getImageData(x, y, 1, 1).data

getCurve = () ->
  points = []
  x = Math.floor(Math.random() * width)
  y = Math.floor(Math.random() * height)
  angle = Math.random() * Math.PI * 2
  for i in [0..30]
    angle += Math.random() * Math.PI * 0.02
    x += Math.sin(angle) * thickness
    y += Math.cos(angle) * thickness
    color = getSample(context, x, y)
    points.push([x, y, color[0], color[1], color[2]])
  return points

drawCurve = (curve, thickness) ->
  c = curve[0]
  x1 = curve[0][0]
  y1 = curve[0][1]
  group = svg.group()
  for c in curve[1..]
    x2 = c[0]
    y2 = c[1]
    r = c[2]
    g = c[3]
    b = c[4]
    l = group.line(x1, y1, x2, y2)
    l.stroke({ width: thickness, color: "rgb(#{r},#{g},#{b})", opacity: 0.4})
    l1 = group.line(x1, y1, x2, y2)
    l1.stroke({ width: thickness/2, color: "rgb(#{r},#{g},#{b})", opacity: 0.8})
    #l.animate().stroke({ opacity: 0})
    #l1.animate().stroke({ opacity: 0})
    x1 = x2
    y1 = y2
  return group


init = (imageUrl) ->
  canvasElement = document.getElementById('canvas')
  imageCanvas = document.getElementById('image')
  width = $(canvasElement).width()
  height = $(canvasElement).height()
  context = imageCanvas.getContext('2d')

  img = new Image()
  img.onload = () ->
    imageCanvas.width = width
    imageCanvas.height = height
    scaleX = width / img.width
    scaleY = height / img.height
    scale = Math.max(scaleX, scaleY)
    context.drawImage(img, 0, 0, img.width * scale, img.height * scale)
    svg = SVG('canvas').size(width, height)

  img.src = imageUrl

  d = () ->
    thickness -= 0.1
    thickness = Math.max(thickness, 10)
    curveData = getCurve()
    curve = drawCurve(curveData, thickness)

  setInterval(d, 300)

$(document).ready(() ->
  init('test.jpg')
)
