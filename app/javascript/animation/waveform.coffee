class Waveform
  constructor: (options) ->
    @container = options.container
    @canvas    = options.canvas
    @data      = options.data || []
    @outerColor = options.outerColor || "transparent"
    @percentPlayed = options.percentPlayed
    unless @canvas?
      if @container
        @canvas = @createCanvas(@container, options.width || @container.clientWidth, options.height || @container.clientHeight)
      else
        throw "Either canvas or container option must be passed"

    @context = @canvas.getContext("2d")
    @width  = parseInt @context.canvas.width, 10
    @height = parseInt @context.canvas.height, 10

    # High DPI Canvas
    devicePixelRatio = window.devicePixelRatio || 1
    backingStoreRatio = @context.webkitBackingStorePixelRatio || @context.mozBackingStorePixelRatio || @context.msBackingStorePixelRatio || @context.oBackingStorePixelRatio || @context.backingStorePixelRatio || 1
    @ratio = devicePixelRatio / backingStoreRatio
    if devicePixelRatio isnt backingStoreRatio
      @canvas.width  = @ratio * @width
      @canvas.height = @ratio * @height
      @canvas.style.width  = "#{@width}px"
      @canvas.style.height = "#{@height}px"
      @context.scale @ratio, @ratio

    if options.data.length < 2 
      options.data = [0,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0.9,1,0]
    scaled = @scale(options.data)
    @setDataInterpolated(scaled)
    @update()
    console.log(@data)

  setData: (data) ->
    @data = data

  setDataInterpolated: (data) ->
    @setData @interpolateArray(data, @width)

  update: () ->
    @redraw()

  scale: (data) ->
    data = data.split(',').map (s) -> parseFloat(s)
    max = Math.max.apply(Math, data)
    min = Math.min.apply(Math, data)
    scale = Math.max(Math.abs(max), Math.abs(min))
    data = data.map (s) -> 
      Math.pow(Math.abs(s) / scale, 0.7)
      
  redraw: () =>
    percentPlayed = @percentPlayed()
    middle = @height / 2
    i = 0
    for d in @data
      t = @width / @data.length
      if((i/@width) < percentPlayed)
        @context.fillStyle = '#353535';
      else
        @context.fillStyle = '#c7c6c3';
      @context.fillRect t*i, middle - middle * d, t, middle * d * 2
      i++

  clear: ->
    @context.fillStyle = @outerColor
    @context.clearRect(0, 0, @width, @height)
    @context.fillRect(0, 0,  @width, @height)

  # rather private helpers:

  createCanvas: (container, width, height) ->
    canvas = document.createElement("canvas")
    container.appendChild(canvas)
    canvas.width  = width
    canvas.height = height
    canvas

  linearInterpolate: (before, after, atPoint) ->
    before + (after - before) * atPoint

  interpolateArray: (data, fitCount) ->
    newData = new Array()
    springFactor = new Number((data.length - 1) / (fitCount - 1))
    newData[0] = data[0]
    i = 1

    while i < fitCount - 1
      tmp = i * springFactor
      before = new Number(Math.floor(tmp)).toFixed()
      after = new Number(Math.ceil(tmp)).toFixed()
      atPoint = tmp - before
      newData[i] = @linearInterpolate(data[before], data[after], atPoint)
      i++
    newData[fitCount - 1] = data[data.length - 1]
    newData

module.exports = Waveform