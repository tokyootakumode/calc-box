'use strict';

var Point  = Isomer.Point;
var Path   = Isomer.Path;
var Shape  = Isomer.Shape;
var Vector = Isomer.Vector;
var Color  = Isomer.Color;

var opacity = 0.7;
var colors = [
  new Color(50, 60, 160, opacity), // blue
  new Color(160, 60, 50, opacity), // red
  new Color(50, 160, 60, opacity), // green
  new Color(50, 200, 0, opacity)   // yellow
];

var box = {
  width: 200,
  height: 200,
  depth: 300
};
var parcels = [
  { width: 100, height: 100, depth: 100, x:   0, y:   0, z:   0, color: colors[0] },
  { width: 100, height: 100, depth: 100, x:   0, y: 100, z:   0, color: colors[1] },
  { width: 100, height: 100, depth: 100, x:   0, y: 100, z: 100, color: colors[2] },
  { width: 100, height: 100, depth: 100, x: 100, y: 100, z: 100, color: colors[3] },
  { width: 100, height: 100, depth: 100, x: 100, y: 200, z: 100, color: colors[0] }
];

var iso = new Isomer(document.getElementById("canvas"));

var spacer = 0.1;
var scale = 4;
var longestSide = Math.max(box.depth, box.width, box.height);
var center = Point((box.depth / longestSide * scale + spacer) * 0.5, (box.width / longestSide * scale + spacer) * 0.5, 0);
var rotate = 0;

var toRadian = function(degrees) {
  return degrees * Math.PI / 180;
}

iso.add(Shape.Prism(
  Point.ORIGIN,
  (box.depth / longestSide) * scale + spacer,
  (box.width / longestSide) * scale + spacer,
  (box.height / longestSide) * scale + spacer
).rotateZ(center, toRadian(rotate)), new Color(222, 222, 222, 0.5));

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
}).forEach(function(parcel) {
  iso.add(Shape.Prism(Point(
    parcel.y / longestSide * scale + spacer,
    parcel.x / longestSide * scale + spacer,
    parcel.z / longestSide * scale
  ),
    parcel.depth / longestSide * scale - spacer * 0.5,
    parcel.width / longestSide * scale - spacer * 0.5,
    parcel.height / longestSide * scale - spacer * 0.5
  ).rotateZ(center, toRadian(rotate)), parcel.color);
});
