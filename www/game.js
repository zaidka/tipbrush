// Generated by CoffeeScript 1.6.3
var NUM_STROKES, SEGMENT_LENGTH, STROKE_WIDTH, canvasContext, canvasElement, currentAlphas, currentDistance, currentStroke, currentX, currentY, drawLine, drawStroke, drawing, fingerDown, fingerMove, fingerUp, getSample, getStroke, height, imageCanvas, imageContext, init, thickness, timeout, width;

NUM_STROKES = 10;

STROKE_WIDTH = 3;

SEGMENT_LENGTH = 10;

imageCanvas = null;

imageContext = null;

canvasElement = null;

canvasContext = null;

width = null;

height = null;

thickness = 10;

drawing = false;

currentX = 0;

currentY = 0;

currentDistance = 0;

currentStroke = null;

currentAlphas = [];

timeout = null;

getSample = function(context, x, y) {
  var d;
  d = context.getImageData(x, y, 1, 1).data;
  return d;
};

getStroke = function() {
  var a, angle, color, i, offset, p, points, x, xo, y, yo, _i, _j;
  points = [];
  x = Math.floor(Math.random() * width);
  y = Math.floor(Math.random() * height);
  angle = Math.random() * Math.PI * 2;
  a = Math.random() * Math.PI * 0.02;
  for (i = _i = 0; _i <= 40; i = ++_i) {
    angle += a;
    x += Math.sin(angle) * SEGMENT_LENGTH;
    y += Math.cos(angle) * SEGMENT_LENGTH;
    p = [x, y, angle];
    for (i = _j = 0; 0 <= NUM_STROKES ? _j < NUM_STROKES : _j > NUM_STROKES; i = 0 <= NUM_STROKES ? ++_j : --_j) {
      offset = i * STROKE_WIDTH - (NUM_STROKES * STROKE_WIDTH * 0.5);
      xo = x + Math.sin(angle + Math.PI * 0.5) * offset;
      yo = y + Math.cos(angle + Math.PI * 0.5) * offset;
      color = getSample(imageContext, xo, yo);
      p.push(color[0], color[1], color[2]);
    }
    points.push(p);
  }
  return points;
};

drawStroke = function(stroke, thickness) {
  var angle, g, i, offset, offsetX, offsetY, p1, p2, _i, _j, _len, _ref, _results;
  p1 = stroke[0];
  _ref = stroke.slice(1);
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    p2 = _ref[_i];
    angle = p2[2];
    for (i = _j = 0; 0 <= NUM_STROKES ? _j < NUM_STROKES : _j > NUM_STROKES; i = 0 <= NUM_STROKES ? ++_j : --_j) {
      offset = i * STROKE_WIDTH - (NUM_STROKES * STROKE_WIDTH * 0.5);
      offsetX = Math.sin(angle + Math.PI * 0.5) * offset;
      offsetY = Math.cos(angle + Math.PI * 0.5) * offset;
      g = canvasContext.createLinearGradient(p1[0] + offsetX, p1[1] + offsetY, p2[0] + offsetX, p2[1] + offsetY);
      g.addColorStop(0, "rgba(" + p1[i * 3 + 3] + "," + p1[i * 3 + 4] + "," + p1[i * 3 + 5] + ", 0.9)");
      g.addColorStop(1, "rgba(" + p2[i * 3 + 3] + "," + p2[i * 3 + 4] + "," + p2[i * 3 + 5] + ", 0.9)");
      canvasContext.beginPath();
      canvasContext.moveTo(p1[0] + offsetX, p1[1] + offsetY);
      canvasContext.strokeStyle = g;
      canvasContext.lineWidth = STROKE_WIDTH + 1;
      canvasContext.lineTo(p2[0] + offsetX, p2[1] + offsetY);
      canvasContext.closePath();
      canvasContext.lineCap = 'round';
      canvasContext.lineJoin = 'round';
      canvasContext.stroke();
    }
    _results.push(p1 = p2);
  }
  return _results;
};

drawLine = function(stroke, thickness) {
  var alpha, p1, p2, _fn, _i, _len, _ref, _results;
  p1 = stroke[0];
  alpha = 1;
  _ref = stroke.slice(1);
  _fn = function(p1, p2, alpha) {
    return setTimeout(function() {
      canvasContext.beginPath();
      canvasContext.strokeStyle = "rgba(255,255,255,1)";
      canvasContext.lineCap = 'round';
      canvasContext.lineJoin = 'round';
      canvasContext.moveTo(p1[0], p1[1]);
      canvasContext.lineWidth = STROKE_WIDTH * 2;
      canvasContext.lineTo(p2[0], p2[1]);
      canvasContext.stroke();
      canvasContext.beginPath();
      canvasContext.strokeStyle = "rgba(50,50,50,1)";
      canvasContext.lineCap = 'round';
      canvasContext.lineJoin = 'round';
      canvasContext.moveTo(p1[0], p1[1]);
      canvasContext.lineWidth = STROKE_WIDTH;
      canvasContext.lineTo(p2[0], p2[1]);
      return canvasContext.stroke();
    }, (1 - alpha) * 300);
  };
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    p2 = _ref[_i];
    alpha -= 1 / stroke.length;
    _fn(p1, p2, alpha);
    _results.push(p1 = p2);
  }
  return _results;
};

init = function(imageUrl) {
  var d, img;
  canvasElement = document.getElementById('canvas');
  imageCanvas = document.getElementById('image');
  width = $(canvasElement).width();
  height = $(canvasElement).height();
  imageContext = imageCanvas.getContext('2d');
  canvasContext = canvasElement.getContext('2d');
  img = new Image();
  img.onload = function() {
    var scale, scaleX, scaleY;
    imageCanvas.width = width;
    imageCanvas.height = height;
    scaleX = width / img.width;
    scaleY = height / img.height;
    scale = Math.max(scaleX, scaleY);
    return imageContext.drawImage(img, 0, 0, img.width * scale, img.height * scale);
  };
  img.src = imageUrl;
  d = function() {
    var stroke, strokeData;
    strokeData = getStroke();
    return stroke = drawStroke(strokeData, thickness);
  };
  canvas.addEventListener('touchstart', function(e) {
    return fingerDown(e.touches[0].pageX, e.touches[0].pageY);
  });
  canvas.addEventListener('touchend', function(e) {
    return fingerUp();
  });
  return canvas.addEventListener('touchmove', function(e) {
    return fingerMove(e.touches[0].pageX, e.touches[0].pageY);
  });
};

fingerDown = function(x, y) {
  var i, _i, _results;
  currentX = x;
  currentY = y;
  currentDistance = 0;
  drawing = true;
  currentAlphas = [];
  _results = [];
  for (i = _i = 0; 0 <= NUM_STROKES ? _i < NUM_STROKES : _i > NUM_STROKES; i = 0 <= NUM_STROKES ? ++_i : --_i) {
    _results.push(currentAlphas.push(Math.random() * 100 - 50));
  }
  return _results;
};

fingerUp = function() {
  drawing = false;
  clearTimeout(timeout);
  return timeout = setTimeout(function() {
    currentStroke = getStroke();
    return drawLine(currentStroke);
  }, 200);
};

fingerMove = function(x, y) {
  var a, a1, a2, alpha, angle, b, b1, b2, blue1, blue2, dX, dY, delta, g, green1, green2, i, newDistance, newX, newY, offset, offsetX, offsetY, red1, red2, _i;
  if (drawing === false) {
    return;
  }
  newX = x;
  newY = y;
  dX = newX - currentX;
  dY = newY - currentY;
  delta = Math.sqrt(dX * dX + dY * dY);
  if (delta < SEGMENT_LENGTH) {
    return;
  }
  angle = Math.atan2(dX, dY);
  newDistance = currentDistance + delta;
  a = currentDistance / SEGMENT_LENGTH;
  a1 = a % 1;
  a2 = 1 - a1;
  b = newDistance / SEGMENT_LENGTH;
  b1 = b % 1;
  b2 = 1 - b1;
  for (i = _i = 0; 0 <= NUM_STROKES ? _i < NUM_STROKES : _i > NUM_STROKES; i = 0 <= NUM_STROKES ? ++_i : --_i) {
    red1 = Math.floor(currentStroke[Math.floor(a)][i * 3 + 3] * a1 + currentStroke[Math.ceil(a)][i * 3 + 3] * a2);
    green1 = Math.floor(currentStroke[Math.floor(a)][i * 3 + 4] * a1 + currentStroke[Math.ceil(a)][i * 3 + 4] * a2);
    blue1 = Math.floor(currentStroke[Math.floor(a)][i * 3 + 5] * a1 + currentStroke[Math.ceil(a)][i * 3 + 5] * a2);
    red2 = Math.floor(currentStroke[Math.floor(b)][i * 3 + 3] * b1 + currentStroke[Math.ceil(b)][i * 3 + 3] * b2);
    green2 = Math.floor(currentStroke[Math.floor(b)][i * 3 + 4] * b1 + currentStroke[Math.ceil(b)][i * 3 + 4] * b2);
    blue2 = Math.floor(currentStroke[Math.floor(b)][i * 3 + 5] * b1 + currentStroke[Math.ceil(b)][i * 3 + 5] * b2);
    offset = i * STROKE_WIDTH - (NUM_STROKES * STROKE_WIDTH * 0.5);
    offsetX = Math.sin(angle + Math.PI * 0.5) * offset;
    offsetY = Math.cos(angle + Math.PI * 0.5) * offset;
    alpha = 1;
    g = canvasContext.createLinearGradient(currentX + offsetX, currentY + offsetY, newX + offsetX, newY + offsetY);
    g.addColorStop(0, "rgba(" + red1 + "," + green1 + "," + blue1 + ", " + alpha + ")");
    g.addColorStop(1, "rgba(" + red2 + "," + green2 + "," + blue2 + ", " + alpha + ")");
    canvasContext.beginPath();
    canvasContext.moveTo(currentX + offsetX, currentY + offsetY);
    canvasContext.strokeStyle = g;
    canvasContext.lineWidth = STROKE_WIDTH + 1;
    canvasContext.lineTo(newX + offsetX, newY + offsetY);
    canvasContext.lineCap = 'round';
    canvasContext.lineJoin = 'round';
    canvasContext.stroke();
  }
  currentDistance = newDistance;
  currentX = newX;
  return currentY = newY;
};

$(document).ready(function() {
  document.getElementById('canvas').width = $('body').innerWidth();
  document.getElementById('canvas').height = $('body').innerHeight();
  init('monalisa.jpg');
  return setTimeout(function() {
    currentStroke = getStroke();
    return drawLine(currentStroke);
  }, 1000);
});
