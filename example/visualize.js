'use strict';

var Point = Isomer.Point;
var Path = Isomer.Path;
var Shape = Isomer.Shape;
var Vector = Isomer.Vector;
var Color = Isomer.Color;

var opacity = 0.7;
var colors = [
  new Color(50, 60, 160, opacity), // blue
  new Color(160, 60, 50, opacity), // red
  new Color(50, 160, 60, opacity), // green
  new Color(50, 200, 0, opacity) // yellow
];

var createFigures = function(boxInfo) {
  var canvas = document.createElement('canvas');
  canvas.width = 400;
  canvas.height = 300;

  if (!boxInfo || !boxInfo.box) {
    return canvas;
  }

  var box = {
    width: boxInfo.box.width,
    height: boxInfo.box.height,
    depth: boxInfo.box.depth
  };
  var parcels = boxInfo.box.parcels.map(function(p, i) {
    p.color = colors[i % colors.length];
    return p;
  });

  var spacer = 0.1;
  var scale = 2;
  var longestSide = Math.max(box.depth, box.width, box.height);
  var center = Point(
    (box.depth / longestSide * scale + spacer) * 0.5,
    (box.width / longestSide * scale + spacer) * 0.5,
    0
  );
  var rotate = 180;

  var toRadian = function(degrees) {
    return degrees * Math.PI / 180;
  };

  var parcelsAnimSet = parcels.map(function(p, i) {
    return parcels.slice(0, i + 1);
  });

  var len = parcelsAnimSet.length;
  var globalIndex = 0;
  var iso;
  setInterval(function() {
    if (globalIndex % len == 0) {
      globalIndex = 0;
      canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
      iso = new Isomer(canvas);
      iso.add(
        Shape.Prism(
          Point.ORIGIN,
          box.depth / longestSide * scale + spacer,
          box.width / longestSide * scale + spacer,
          box.height / longestSide * scale + spacer
        ).rotateZ(center, toRadian(rotate)),
        new Color(222, 222, 222, 0.5)
      );
    }
    var parcels = parcelsAnimSet[globalIndex++];
    /*
    parcels.sort(function(a, b) {
      // 奥から手前、左から右、下から上に描画
      if (rotate >= 225) {
        if (a.x > b.x) { return -1; }
        if (a.x < b.x) { return  1; }
        if (a.y > b.y) { return  1; }
        if (a.y < b.y) { return -1; }
      } else if (rotate >= 135) {
        if (a.x > b.x) { return  1; }
        if (a.x < b.x) { return -1; }
        if (a.y > b.y) { return  1; }
        if (a.y < b.y) { return -1; }
      } else if (rotate >= 45) {
        if (a.x > b.x) { return  1; }
        if (a.x < b.x) { return -1; }
        if (a.y > b.y) { return -1; }
        if (a.y < b.y) { return  1; }
      } else {
        if (a.x > b.x) { return -1; }
        if (a.x < b.x) { return  1; }
        if (a.y > b.y) { return -1; }
        if (a.y < b.y) { return  1; }
      }
      if (a.z > b.z) { return  1; }
      if (a.z < b.z) { return -1; }

      return 0;
    })
    */
    parcels.forEach(function(parcel) {
      iso.add(
        Shape.Prism(
          Point(
            parcel.y / longestSide * scale + spacer,
            parcel.x / longestSide * scale + spacer,
            parcel.z / longestSide * scale
          ),
          parcel.depth / longestSide * scale - spacer * 0.5,
          parcel.width / longestSide * scale - spacer * 0.5,
          parcel.height / longestSide * scale - spacer * 0.5
        ).rotateZ(center, toRadian(rotate)),
        parcel.color
      );
    });
  }, 500);

  return canvas;
};

var page = 1;
var boxes = window.boxes.filter(function(boxInfo) {
  return boxInfo.box === null || boxInfo.box.parcels.length > 1;
});

for (var i = 0, ilen = Math.min(boxes.length, 4); i < ilen; ++i) {
  for (var j = 0, jlen = Math.min(boxes.length, 4); j < jlen; ++j) {
    var idx = (page - 1) * ilen * jlen + i * jlen + j;
    var boxInfo = boxes[idx];
    var box = boxInfo.box;
    var canvas = createFigures(boxInfo);
    var container = document.createElement('div');
    container.style.display = 'inline-block';
    container.style.float = 'left';
    var text = document.createElement('p');
    text.innerText = boxInfo.text;
    container.appendChild(text);
    container.appendChild(canvas);
    document.querySelector('body').appendChild(container);
  }
}
