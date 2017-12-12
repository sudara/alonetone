function Triangulr (width, height, lineHeight, pointArea, renderingFunction) {

  // Tests
  if (typeof width !== 'number' || width <= 0) {
    throw 'Triangulr: width must be positive';
  }
  if (typeof height !== 'number' || height <= 0) {
    throw 'Triangulr: height must be positive';
  }
  if (typeof lineHeight !== 'number' || lineHeight <= 0) {
    throw 'Triangulr: lineHeight must be set and be positive number';
  }
  if (!!pointArea && typeof pointArea !== 'number' || pointArea < 0) {
    throw 'Triangulr: pointArea must be set and be a positive number';
  }
  if (!!renderingFunction && typeof renderingFunction !== 'function') {
    throw 'Triangulr: renderingFunction must be a function';
  }

  // Save input
  this.mapWidth = width;
  this.mapHeight = height;
  this.lineHeight = lineHeight;
  this.pointArea = !!pointArea ? pointArea : 0;
  this.colorRendering = !!renderingFunction ? renderingFunction : this.generateGray;

  this.triangleLine = Math.sqrt(Math.pow(lineHeight/2, 2) + Math.pow(lineHeight, 2));
  this.originX = - this.triangleLine;
  this.originY = - this.lineHeight;
  this.lines = [];
  this.exportData = [];

  this.lineMapping();
  this.createTriangles();
  return this.generateDom();
}

/**
 * lineMapping
 * generate this.lines from the contructor info
 *
 */
Triangulr.prototype.lineMapping = function () {

  var x, y, line;
  var lineX = Math.ceil(this.mapWidth/this.triangleLine) + 4;
  var lineY = Math.ceil(this.mapHeight/this.lineHeight) + 2;
  var parite = this.triangleLine/4;

  for(y = 0; y<lineY; y++) {
    line = [];
    for(x = 0; x<lineX; x++) {
      line.push({
        x: x * this.triangleLine + Math.round(Math.random() * this.pointArea * 2) - this.pointArea + this.originX + parite,
        y: y * this.lineHeight + Math.round(Math.random() * this.pointArea * 2) - this.pointArea + this.originX
      });
    }
    this.lines.push(line);
    parite *= -1;
  }
};

/**
 * createTriangles
 * use points form this.lines to generate triangles
 * and put them into this.exportData
 *
 */
Triangulr.prototype.createTriangles = function () {

  var x, parite, lineA, lineB, aIndex, bIndex, points, poly, pointsList;
  var counter = 0;
  var lineParite = true;
  this.exportData = [];

  for(x = 0; x<this.lines.length -1; x++) {
    lineA = this.lines[x];
    lineB = this.lines[x+1];
    aIndex = 0;
    bIndex = 0;
    parite = lineParite;

    do {
      // Get the good points
      points = [lineA[aIndex], lineB[bIndex]];
      if (parite) {
        bIndex++;
        points.push(lineB[bIndex]);
      }
      else {
        aIndex++;
        points.push(lineA[aIndex]);
      }
      parite = !parite;

      // Save the triangle
      pointsList = [
        points[0],
        points[1],
        points[2]
      ];
      this.exportData.push({
        style: {
          fill: this.colorRendering({
            counter: counter,
            x: aIndex + bIndex - 1,
            y: x,
            lines: this.lines.length,
            cols: (lineA.length - 2) * 2,
            points: pointsList
          })
        },
        points: pointsList
      });
      counter++;
    } while (aIndex != lineA.length-1 && bIndex != lineA.length-1);

    lineParite = !lineParite;
  }
};

/**
 * generateDom
 * generate the SVG object from exportData content
 *
 * @return {[object]} Svg DOM object
 */
Triangulr.prototype.generateDom = function () {
  var i, j, data, points, style, polygon;
  var svgTag = document.createElementNS('http://www.w3.org/2000/svg','svg');
  var output = '';

  svgTag.setAttribute('version', '1.1');
  svgTag.setAttribute('viewBox', '0 0 ' + this.mapWidth + ' ' + this.mapHeight);
  svgTag.setAttribute('enable-background', 'new 0 0 ' + this.mapWidth + ' ' + this.mapHeight);
  svgTag.setAttribute('preserveAspectRatio', 'xMinYMin slice');

  for(i in this.exportData) {
    data = this.exportData[i];
    polygon = document.createElementNS('http://www.w3.org/2000/svg','path');

    points   = 'M' + data.points[0].x + ' ' + data.points[0].y + ' ';
    points  += 'L' + data.points[1].x + ' ' + data.points[1].y + ' ';
    points  += 'L' + data.points[2].x + ' ' + data.points[2].y + ' Z';
    polygon.setAttribute('d', points);
    polygon.setAttribute('fill', data.style.fill);
    //polygon.setAttribute('shape-rendering', 'geometricPrecision');
    //polygon.setAttribute('shape-rendering', 'crispEdges');

    svgTag.appendChild(polygon);
  }
  return svgTag;
};

/**
 * generateGray
 * default color generator when no function is
 * given to the constructor
 * it generate dark grey colors
 *
 * @param  {[object]} path Info object relative to current triangle
 * @return {[string]}      Color generated
 */
Triangulr.prototype.generateGray = function (path) {
  var code = Math.floor(Math.random()*5).toString(16);
  code += Math.floor(Math.random()*16).toString(16);
  return '#'+code+code+code;
};

// Exports
if (typeof define === 'function' && define.amd) {
  // AMD. Register as an anonymous module.
  define([], function() {
    return Triangulr;
  });
} else if (typeof exports === 'object') {
  // Node. Does not work with strict CommonJS, but
  // only CommonJS-like environments that support module.exports,
  // like Node.
  module.exports = Triangulr;
} else {
  // Browser globals
  window.Triangulr = Triangulr;
}

function randomBetween(min, max) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

var colorGenerator = function (path) {
  var random = 32;
  var ratio = (path.x * path.y) / (path.cols * path.lines);
  var code = Math.floor(255 - (ratio * (255-random)) - Math.random()*random).toString(16);
 var color = '#'+code+code+code;
 //console.log(color)
  return color;
};/*
svg = new Triangulr (960, 400, 80, 40, colorGenerator); */

function getRandomColor() {
  var letters = '123456789ABCDEF';
  var color = '#';
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 15)];
  }
 //console.log(color)
  return color;
}

function getGreenColor(){
 var max = 10;
 var min = 200;
 var green = Math.floor(Math.random() * (max - min + 1)) + min;
 return "rgb(0," + green + ",0)";
}

function getPurpleColor(){
 var max = 150;
 var min = 120;
 var blue = Math.floor(Math.random() * (max - min + 1)) + min;
 var red = Math.floor(Math.random() * (max - min + 1)) + min;
 //return "rgb(0," + green + ",0)";
 return "rgb("+red+", 0," + blue + ")";
}

// adapted from: https://gist.github.com/aemkei/1325937
function hsl2rgb(h, s, b){
    h *= 6;
    s = [
        b += s *= b < .5 ? b : 1 - b,
        b - h % 1 * s * 2,
        b -= s *= 2,
        b,
        b + h % 1 * s,
        b + s
    ];

    return "rgb(" +
        Math.floor(s[ ~~h    % 6 ] * 255) + "," + // red
        Math.floor(s[ (h|16) % 6 ] * 255) + "," + // green
        Math.floor(s[ (h|8)  % 6 ] * 255) + ")" // blue
}


// modified from https://github.com/stewartlord/identicon.js/blob/master/identicon.js
function colorFromHash(hash){
  // grab last 7 chars
  var hue = parseInt(hash.substr(-7), 16) / 0xfffffff;
  var saturation = .7
  var brightness = .7
  return function(){ hsl2rgb(hue, saturation, brightness)}
}

function colorsFromAHue(hue){
  var saturation = randomBetween(75,100)/100
  var brightness = randomBetween(10,50)/100
  return hsl2rgb(hue, saturation, brightness)
}

function booleanFromHashDigit(digit){
  return parseInt(digit, 16) % 2
}

function integerRangeFromHashDigit(digit, min, max){
  var multiplier = parseInt(digit, 16) / 15 // 0.0 to 1.0
  var range = max - min
  var selection = Math.floor(multiplier * range)
  return min + selection
}
//var mySVG = new Triangulr (800, 600, 8, 40, getGreenColor);
//var mySVG = new Triangulr (800, 600, 8, 200, getPurpleColor);
//var mySVG = new Triangulr (800, 600, 28, 23, colorGenerator);

function makeSVGFromTitle(height, title){
  Math.seedrandom(title); // this makes all .random calls repeatable per album

  var lineHeight = randomBetween(height/20, height/10)
  var pointArea =  randomBetween(0, 40)
  var hue = Math.random()

  // this keeps the hue consistent across albums
  var colorFunction = colorsFromAHue.bind(null, hue)
  console.log('lineheight is ' + lineHeight + ' and pointArea is ' + pointArea)
  return new Triangulr (height, height, lineHeight, pointArea, colorFunction);
}

//var mySVG = new Triangulr (800, 600, 80, 400, getRandomColor);

/* new TimelineMax().staggerTo('path', 0.5, {
 //alpha:0,
 scale:4,
 cycle:{
  duration:[7,3,4.2,7,3,8.6],
  rotation:function(i){
   return randomBetween(10, 23)
  },
 },
 transformOrigin:'0% 0%',
 //transformOrigin:'50% 100%',

 repeat:-1,
 //ease:Expo.easeIn,
 yoyo:true
},1.05).seek(10000)

 */