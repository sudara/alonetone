/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
class Waveform {
  constructor(options) {
    this.redraw = this.redraw.bind(this);
    this.container = options.container;
    this.canvas = options.canvas;
    this.data = options.data || [];
    this.outerColor = options.outerColor || "transparent";
    this.percentPlayed = options.percentPlayed;
    if (this.canvas == null) {
      if (this.container) {
        this.canvas = this.createCanvas(this.container, options.width || this.container.clientWidth, options.height || this.container.clientHeight);
      } else {
        throw "Either canvas or container option must be passed";
      }
    }

    this.context = this.canvas.getContext("2d");
    this.width = parseInt(this.context.canvas.width, 10);
    this.height = parseInt(this.context.canvas.height, 10);

    // High DPI Canvas
    const devicePixelRatio = window.devicePixelRatio || 1;
    const backingStoreRatio = this.context.webkitBackingStorePixelRatio || this.context.mozBackingStorePixelRatio || this.context.msBackingStorePixelRatio || this.context.oBackingStorePixelRatio || this.context.backingStorePixelRatio || 1;
    this.ratio = devicePixelRatio / backingStoreRatio;
    if (devicePixelRatio !== backingStoreRatio) {
      this.canvas.width = this.ratio * this.width;
      this.canvas.height = this.ratio * this.height;
      this.canvas.style.width = `${this.width}px`;
      this.canvas.style.height = `${this.height}px`;
      this.context.scale(this.ratio, this.ratio);
    }

    if (options.data.length < 2) {
      options.data = [0, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0];
    } else {
      options.data = options.data.split(',').map(s => parseFloat(s));
    }
    const scaled = this.scale(options.data);
    this.setDataInterpolated(scaled);
    this.update();
  }

  setData(data) {
    return this.data = data;
  }

  setDataInterpolated(data) {
    return this.setData(this.interpolateArray(data, this.width));
  }

  update() {
    return this.redraw();
  }

  scale(data) {
    const max = Math.max.apply(Math, data);
    const min = Math.min.apply(Math, data);
    const scale = Math.max(Math.abs(max), Math.abs(min));
    return data = data.map(s => Math.pow(Math.abs(s) / scale, 0.7));
  }

  redraw() {
    const percentPlayed = this.percentPlayed();
    const middle = this.height / 2;
    let i = 0;
    return (() => {
      const result = [];
      for (let d of Array.from(this.data)) {
        const t = this.width / this.data.length;
        if ((i / this.width) < percentPlayed) {
          this.context.fillStyle = '#353535';
        } else {
          this.context.fillStyle = '#c7c6c3';
        }
        this.context.fillRect(t * i, middle - (middle * d), t, (middle * d * 2) + 1);
        result.push(i++);
      }
      return result;
    })();
  }

  clear() {
    this.context.fillStyle = this.outerColor;
    this.context.clearRect(0, 0, this.width, this.height);
    return this.context.fillRect(0, 0, this.width, this.height);
  }

  // rather private helpers:

  createCanvas(container, width, height) {
    const canvas = document.createElement("canvas");
    container.appendChild(canvas);
    canvas.width = width;
    canvas.height = height;
    return canvas;
  }

  linearInterpolate(before, after, atPoint) {
    return before + ((after - before) * atPoint);
  }

  interpolateArray(data, fitCount) {
    const newData = new Array();
    const springFactor = new Number((data.length - 1) / (fitCount - 1));
    newData[0] = data[0];
    let i = 1;

    while (i < (fitCount - 1)) {
      const tmp = i * springFactor;
      const before = new Number(Math.floor(tmp)).toFixed();
      const after = new Number(Math.ceil(tmp)).toFixed();
      const atPoint = tmp - before;
      newData[i] = this.linearInterpolate(data[before], data[after], atPoint);
      i++;
    }
    newData[fitCount - 1] = data[data.length - 1];
    return newData;
  }
}

module.exports = Waveform;