class Waveform
  constructor: (options) ->
    @container = options.container
    @canvas    = options.canvas
    @data      = options.data || []
    @outerColor = options.outerColor || "transparent"
    @innerColor = options.innerColor || "#000000"
    @interpolate = true
    @interpolate = false if options.interpolate == false
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

    if options.data
      @update(options)

  setData: (data) ->
    @data = data

  setDataInterpolated: (data) ->
    @setData @interpolateArray(data, @width)

  setDataCropped: (data) ->
    @setData @expandArray(data, @width)

  update: (options) ->
    if options.interpolate?
      @interpolate = options.interpolate
    if @interpolate == false
      @setDataCropped(options.data)
    else
      @setDataInterpolated(options.data)
    @redraw()

  redraw: () =>
    @clear()
    if typeof(@innerColor) == "function"
      @context.fillStyle = @innerColor()
    else
      @context.fillStyle = @innerColor
    middle = @height / 2
    i = 0
    for d in @data
      t = @width / @data.length
      @context.fillStyle = @innerColor(i/@width, d) if typeof(@innerColor) == "function"
      @context.clearRect t*i, middle - middle * d, t, (middle * d * 2)
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

  expandArray: (data, limit, defaultValue=0.0) ->
    newData = []
    if data.length > limit
      newData = data.slice(data.length - limit, data.length)
    else
      for i in [0..limit-1]
        newData[i] = data[i] || defaultValue
    newData

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


  optionsForSyncedStream: (options={}) ->
    innerColorWasSet = false
    that = this
    {
      whileplaying: @redraw
      whileloading: () ->
        unless innerColorWasSet
          stream = this
          that.innerColor = (x, y) ->
            if x < stream.position / stream.durationEstimate
              options.playedColor || "rgba(255,  102, 0, 0.8)"
            else if x < stream.bytesLoaded / stream.bytesTotal
              options.loadedColor || "rgba(0, 0, 0, 0.8)"
            else
              options.defaultColor || "rgba(0, 0, 0, 0.4)"
          innerColorWasSet = true
        @redraw
    }

module.exports = Waveform