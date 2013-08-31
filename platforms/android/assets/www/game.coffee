NUM_STROKES = 10
STROKE_WIDTH = 3
SEGMENT_LENGTH = 10
imageCanvas = null
imageContext = null
canvasElement = null
canvasContext = null
width = null
height = null
thickness = 10
drawing = false

currentX = 0
currentY = 0
currentDistance = 0
currentStroke = null
currentAlphas = []

timeout = null

getSample = (context, x, y) ->
  # TODO anti aliasing
  d = context.getImageData(x, y, 1, 1).data
  return d


getStroke = () ->
  points = []
  x = Math.floor(Math.random() * width)
  y = Math.floor(Math.random() * height)
  angle = Math.random() * Math.PI * 2
  a = Math.random() * Math.PI * 0.02
  for i in [0..40]
    angle += a
    x += Math.sin(angle) * SEGMENT_LENGTH
    y += Math.cos(angle) * SEGMENT_LENGTH
    p = [x, y, angle]

    for i in [0...NUM_STROKES]
      offset = i * STROKE_WIDTH - (NUM_STROKES * STROKE_WIDTH * 0.5)
      xo = x + Math.sin(angle + Math.PI * 0.5) * offset
      yo = y + Math.cos(angle + Math.PI * 0.5) * offset
      color = getSample(imageContext, xo, yo)
      p.push(color[0], color[1], color[2])
    points.push(p)
  return points


drawStroke = (stroke, thickness) ->
  p1 = stroke[0]
  for p2 in stroke[1..]
    angle = p2[2]
    for i in [0...NUM_STROKES]
      offset = i * STROKE_WIDTH - (NUM_STROKES * STROKE_WIDTH * 0.5)
      offsetX = Math.sin(angle + Math.PI * 0.5) * offset
      offsetY = Math.cos(angle + Math.PI * 0.5) * offset

      #alert(offset)
      g = canvasContext.createLinearGradient(p1[0]+offsetX, p1[1]+offsetY, p2[0]+offsetX, p2[1]+offsetY)
      #alert(g)

      g.addColorStop(0, "rgba(#{p1[i*3+3]},#{p1[i*3+4]},#{p1[i*3+5]}, 0.9)")
      g.addColorStop(1, "rgba(#{p2[i*3+3]},#{p2[i*3+4]},#{p2[i*3+5]}, 0.9)")

      canvasContext.beginPath()
      canvasContext.moveTo(p1[0]+offsetX, p1[1]+offsetY)
      canvasContext.strokeStyle = g
      canvasContext.lineWidth = STROKE_WIDTH + 1
      canvasContext.lineTo(p2[0]+offsetX, p2[1]+offsetY)
      canvasContext.closePath()
      canvasContext.lineCap = 'round'
      canvasContext.lineJoin = 'round'
      canvasContext.stroke()
    p1 = p2


drawLine = (stroke, thickness) ->
  p1 = stroke[0]
  alpha = 1

  for p2 in stroke[1..]
    alpha -= 1 / stroke.length
    do (p1, p2, alpha) ->
      setTimeout(() ->
        canvasContext.beginPath()
        canvasContext.strokeStyle = "rgba(255,255,255,1)"
        canvasContext.lineCap = 'round'
        canvasContext.lineJoin = 'round'
        canvasContext.moveTo(p1[0], p1[1])
        canvasContext.lineWidth = STROKE_WIDTH * 2
        canvasContext.lineTo(p2[0], p2[1])
        canvasContext.stroke()

        canvasContext.beginPath()
        canvasContext.strokeStyle = "rgba(50,50,50,1)"
        canvasContext.lineCap = 'round'
        canvasContext.lineJoin = 'round'
        canvasContext.moveTo(p1[0], p1[1])
        canvasContext.lineWidth = STROKE_WIDTH
        canvasContext.lineTo(p2[0], p2[1])
        canvasContext.stroke()
      , (1 - alpha) * 300)
    p1 = p2
  #canvasContext.closePath()
  #canvasContext.stroke()

  


init = (imageUrl) ->
  canvasElement = document.getElementById('canvas')
  imageCanvas = document.getElementById('image')
  width = $(canvasElement).width()
  height = $(canvasElement).height()
  imageContext = imageCanvas.getContext('2d')
  canvasContext = canvasElement.getContext('2d')

  img = new Image()
  img.onload = () ->
    imageCanvas.width = width
    imageCanvas.height = height
    scaleX = width / img.width
    scaleY = height / img.height
    scale = Math.max(scaleX, scaleY)
    imageContext.drawImage(img, 0, 0, img.width * scale, img.height * scale)

  img.src = imageUrl

  d = () ->
    #thickness *= 0.9
    #thickness = Math.max(thickness, 4)
    #thickness = 10
    #STROKE_WIDTH = thickness
    strokeData = getStroke()
    stroke = drawStroke(strokeData, thickness)
  #setInterval(() ->
  #  d()
  #, 100)

  # canvas.addEventListener('mousedown', (e) ->
  #   fingerDown(e.clientX, e.clientY)
  # )
  # canvas.addEventListener('mouseup', (e) ->
  #   fingerUp(e.clientX, e.clientY)
  # )
  # canvas.addEventListener('mousemove', (e) ->
  #   fingerMove(e.clientX, e.clientY)
  # )

  canvas.addEventListener('touchstart', (e) ->
    fingerDown(e.touches[0].pageX, e.touches[0].pageY)
  )
  canvas.addEventListener('touchend', (e) ->
    fingerUp()
  )
  canvas.addEventListener('touchmove', (e) ->
    fingerMove(e.touches[0].pageX, e.touches[0].pageY)
  )

fingerDown = (x, y) ->
  currentX = x
  currentY = y
  currentDistance = 0
  drawing = true
  currentAlphas = []
  for i in [0...NUM_STROKES]
    currentAlphas.push(Math.random() * 100 - 50)

fingerUp = () ->
  drawing = false
  clearTimeout(timeout)
  timeout = setTimeout(() ->
    currentStroke = getStroke()
    drawLine(currentStroke)
  , 200)

fingerMove = (x, y) ->
  return if drawing == false
  newX = x
  newY = y
  dX = newX - currentX
  dY = newY - currentY
  delta = Math.sqrt(dX * dX + dY * dY) 
  return if delta < SEGMENT_LENGTH
  angle = Math.atan2(dX, dY)
  newDistance = currentDistance + delta
  a = currentDistance / SEGMENT_LENGTH
  a1 = a % 1
  a2 = 1 - a1

  b = newDistance / SEGMENT_LENGTH
  b1 = b % 1
  b2 = 1 - b1

  for i in [0...NUM_STROKES]
    red1 = Math.floor(currentStroke[Math.floor(a)][i * 3 + 3] * a1 + currentStroke[Math.ceil(a)][i * 3 + 3] * a2)
    green1 = Math.floor(currentStroke[Math.floor(a)][i * 3 + 4] * a1 + currentStroke[Math.ceil(a)][i * 3 + 4] * a2)
    blue1 = Math.floor(currentStroke[Math.floor(a)][i * 3 + 5] * a1 + currentStroke[Math.ceil(a)][i * 3 + 5] * a2)
    red2 =  Math.floor(currentStroke[Math.floor(b)][i * 3 + 3] * b1 + currentStroke[Math.ceil(b)][i * 3 + 3] * b2)
    green2 = Math.floor(currentStroke[Math.floor(b)][i * 3 + 4] * b1 + currentStroke[Math.ceil(b)][i * 3 + 4] * b2)
    blue2 = Math.floor(currentStroke[Math.floor(b)][i * 3 + 5] * b1 + currentStroke[Math.ceil(b)][i * 3 + 5] * b2)

    offset = i * STROKE_WIDTH - (NUM_STROKES * STROKE_WIDTH * 0.5)
    offsetX = Math.sin(angle + Math.PI * 0.5) * offset
    offsetY = Math.cos(angle + Math.PI * 0.5) * offset

    alpha = 1#Math.min(1, (currentAlphas[i] + currentDistance) / 50)

    g = canvasContext.createLinearGradient(currentX+offsetX, currentY+offsetY, newX+offsetX, newY+offsetY);
    g.addColorStop(0, "rgba(#{red1},#{green1},#{blue1}, #{alpha})");
    g.addColorStop(1, "rgba(#{red2},#{green2},#{blue2}, #{alpha})");

    canvasContext.beginPath()
    canvasContext.moveTo(currentX+offsetX, currentY+offsetY)
    canvasContext.strokeStyle = g
    canvasContext.lineWidth = STROKE_WIDTH + 1
    canvasContext.lineTo(newX+offsetX, newY+offsetY)
    canvasContext.lineCap = 'round'
    canvasContext.lineJoin = 'round'
    canvasContext.stroke()
  currentDistance = newDistance
  currentX = newX
  currentY = newY



$(document).ready(() ->
  document.getElementById('canvas').width = $('body').innerWidth()
  document.getElementById('canvas').height = $('body').innerHeight()
  init('monalisa.jpg')
  setTimeout(() ->
    currentStroke = getStroke()
    drawLine(currentStroke)
  , 1000)
)
