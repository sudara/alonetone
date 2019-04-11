const seedrandom = require('seedrandom')

function Triangulr (props) {

  // Tests
  if (typeof props.width !== 'number' || props.width <= 0) {
    throw 'Triangulr: width must be positive';
  }
  if (typeof props.height !== 'number' || props.height <= 0) {
    throw 'Triangulr: height must be positive';
  }
  if (typeof props.lineHeight !== 'number' || props.lineHeight <= 0) {
    throw 'Triangulr: lineHeight must be set and be positive number';
  }
  if (!!props.pointArea && typeof props.pointArea !== 'number' || props.pointArea < 0) {
    throw 'Triangulr: pointArea must be set and be a positive number';
  }
/*  if (!!props.strokeWidth && typeof props.strokeWidth !== 'number' || props.strokeWidth < 0) {
    throw 'Triangulr: strokeWidth must be set and be a positive number';
  } */
  if (!!props.renderingFunction && typeof props.renderingFunction !== 'function') {
    throw 'Triangulr: renderingFunction must be a function';
  }

  // Save input
  this.mapWidth = props.width*2;
  this.mapHeight = props.height*2;
  this.lineHeight = props.lineHeight;
  this.pointArea = !!props.pointArea ? props.pointArea : 0;
  this.strokeWidth = !!props.strokeWidth ? props.strokeWidth : 1;
  this.colorRendering = !!props.renderingFunction ? props.renderingFunction : this.generateGray;

  this.triangleLine = Math.sqrt(Math.pow(this.lineHeight/2, 2) + Math.pow(this.lineHeight, 2));
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
  var defsTag = document.createElementNS('http://www.w3.org/2000/svg','defs');
  var gTag = document.createElementNS('http://www.w3.org/2000/svg','g');
  var output = '';

  svgTag.setAttribute('viewBox', '20 0 ' + this.mapWidth/2 + ' ' + this.mapHeight/2);
  svgTag.setAttribute('preserveAspectRatio', 'xMinYMin slice');
  //gTag.setAttribute('filter', 'url(#edgeClean)');

  for(i in this.exportData) {
    data = this.exportData[i];
    polygon = document.createElementNS('http://www.w3.org/2000/svg','path');

    points   = 'M' + data.points[0].x + ' ' + data.points[0].y + ' ';
    points  += 'L' + data.points[1].x + ' ' + data.points[1].y + ' ';
    points  += 'L' + data.points[2].x + ' ' + data.points[2].y + ' Z';
    //points  += 'L' + data.points[2].x + ' ' + data.points[1].y + ' Z';
    polygon.setAttribute('d', points);
    polygon.setAttribute('fill', data.style.fill);
    polygon.setAttribute('stroke', data.style.fill);
    if(this.strokeWidth > 1){
      // if there's a large stroke with, lets curve
      polygon.setAttribute('stroke-linecap', 'round');
      polygon.setAttribute('stroke-width', this.strokeWidth);
      polygon.setAttribute('stroke-linejoin', 'round');
    }else{
      polygon.setAttribute('stroke-width', this.strokeWidth);
    }
    //polygon.setAttribute('shape-rendering', 'geometricPrecision');
    //polygon.setAttribute('shape-rendering', 'crispEdges');

    gTag.appendChild(polygon);
  }
  //console.log(this.cleanEdge())
  svgTag.appendChild(defsTag);
  defsTag.appendChild(this.cleanEdge());
  svgTag.appendChild(gTag);
  return svgTag;
};
Triangulr.prototype.cleanEdge = function () {

  var filterTag = document.createElementNS('http://www.w3.org/2000/svg','filter');
  var feComponentTransfer = document.createElementNS('http://www.w3.org/2000/svg','feComponentTransfer');
  var feFuncA = document.createElementNS('http://www.w3.org/2000/svg','feFuncA');
  feComponentTransfer.appendChild(feFuncA);
  filterTag.appendChild(feComponentTransfer);

  var output = '';
  filterTag.setAttribute('color-interpolation-filters', 'sRGB');
  filterTag.setAttribute('id', 'edgeClean');
  feFuncA.setAttribute('type', 'table');
  feFuncA.setAttribute('tableValues', '0 .5 1 1');
  //console.log(filterTag);
  return filterTag;

}
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

function colorsFromAHue(hue){
  //var saturation = randomBetween(35,100)/100
  var saturation = randomBetween(25,100)/100
  var brightness = randomBetween(10,50)/100
  return hsl2rgb(hue, saturation, brightness)
}

//var mySVG = new Triangulr (800, 600, 8, 40, getGreenColor);
//var mySVG = new Triangulr (800, 600, 8, 200, getPurpleColor);
//var mySVG = new Triangulr (800, 600, 28, 23, colorGenerator);

export function makeSVGFromTitle(height, title){
  seedrandom(title); // this makes all .random calls repeatable per album

  var lineHeight = randomBetween(height/20, height/10)
  var pointArea =  randomBetween(10, 40)
  var whichColorFunction = Math.random()
  if(whichColorFunction > .15){
    var hue = Math.random() // keep the hue for a whole album
    var colorFunction = colorsFromAHue.bind(null, hue)
  }else{
    var colorFunction = getRandomColor
  }

  // do we want circle shapes or just triangles?
  if(Math.random() > .85)
    var strokeWidth = randomBetween(10,50)
  else
    var strokeWidth = .2


  //console.log('lineheight is ' + lineHeight + ' and pointArea is ' + pointArea);
  var props = {width:200, height:200, lineHeight:lineHeight, pointArea:pointArea, strokeWidth:strokeWidth, renderingFunction:colorFunction}
  return new Triangulr (props);
}

//var mySVG = new Triangulr (800, 600, 80, 400, getRandomColor);
