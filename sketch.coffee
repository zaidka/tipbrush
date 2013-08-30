canvas = document.querySelector("#whiteboard")
r = 4
g = 10
b = 20
r2 = 50
g2 = 150
b2 = 220
t_r = 4
t_g = 10
t_b = 20
ctx = canvas.getContext("2d")
sketch = document.querySelector("#container")
sketch_style = getComputedStyle(sketch)
canvas.width = parseInt(sketch_style.getPropertyValue("width"))
canvas.height = parseInt(sketch_style.getPropertyValue("height"))
mouse =
  x: 0
  y: 0

last_mouse =
  x: 0
  y: 0

ctx.lineWidth = 5 #to get it from zaid 
ctx.lineJoin = "round"
ctx.lineCap = "round"

canvas.addEventListener "mousemove", ((e) ->
  last_mouse.x = mouse.x
  last_mouse.y = mouse.y
  mouse.x = e.clientX
  mouse.y = e.clientY
), false

canvas.addEventListener "mousedown", ((e) ->
  canvas.addEventListener "mousemove", onPaint, false
), false

canvas.addEventListener "mouseup", (->
  t_r = r
  t_g = g
  t_b = b
  canvas.removeEventListener "mousemove", onPaint, false
), false

canvas.addEventListener "touchmove", ((e) ->
  last_mouse.x = mouse.x
  last_mouse.y = mouse.y
  mouse.x = e.touches[0].pageX
  mouse.y = e.touches[0].pageY
), false

canvas.addEventListener "touchstart", ((e) ->
  canvas.addEventListener "touchmove", onPaint, false
), false

canvas.addEventListener "touchend", (->
  canvas.removeEventListener "touchmove", onPaint, false
), false

onPaint = ->
  get_color()
  ctx.strokeStyle = "rgb(#{Math.floor(t_r + 0.49)}, #{Math.floor(t_g + 0.49)}, #{Math.floor(t_b + 0.49)})"
  ctx.beginPath()
  ctx.moveTo last_mouse.x, last_mouse.y
  ctx.lineTo mouse.x, mouse.y
  ctx.closePath()
  ctx.stroke()

get_color = ->
  t_r = t_r + (r2 - t_r) * 0.01
  t_g = t_g + (g2 - t_g) * 0.01
  t_b = t_b + (b2 - t_b) * 0.01
