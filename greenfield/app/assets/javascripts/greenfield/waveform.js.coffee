window.Waveform = class Waveform
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

    @patchCanvasForIE(@canvas)
    @context = @canvas.getContext("2d")
    @width  = parseInt @context.canvas.width, 10
    @height = parseInt @context.canvas.height, 10

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

  patchCanvasForIE: (canvas) ->
    if typeof window.G_vmlCanvasManager != "undefined"
     canvas = window.G_vmlCanvasManager.initElement(canvas)
     oldGetContext = canvas.getContext
     canvas.getContext = (a) ->
       ctx = oldGetContext.apply(canvas, arguments)
       canvas.getContext = oldGetContext
       ctx

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

  dataFromSoundCloudTrack: (track) ->
    JSONP.get "http://www.waveformjs.org/w", {url: track.waveform_url}, (data) =>
      @update
        data: data

# Lightweight JSONP fetcher, Copyright 2010-2012 Erik Karlsson. All rights reserved, BSD licensed
# https://github.com/IntoMethod/Lightweight-JSONP/blob/master/jsonp.js
JSONP = (->
  load = (url) ->
    script = document.createElement("script")
    done = false
    script.src = url
    script.async = true
    script.onload = script.onreadystatechange = ->
      if not done and (not @readyState or @readyState is "loaded" or @readyState is "complete")
        done = true
        script.onload = script.onreadystatechange = null
        script.parentNode.removeChild script  if script and script.parentNode

    head = document.getElementsByTagName("head")[0]  unless head
    head.appendChild script
  encode = (str) ->
    encodeURIComponent str
  jsonp = (url, params, callback, callbackName) ->
    query = (if (url or "").indexOf("?") is -1 then "?" else "&")

    callbackName = callbackName or config["callbackName"] or "callback"
    uniqueName = callbackName + "_json" + (++counter)

    params = params or {}
    for key of params
      query += encode(key) + "=" + encode(params[key]) + "&"  if params.hasOwnProperty(key)

    window[uniqueName] = (data) ->
      callback data
      try
        delete window[uniqueName]
      window[uniqueName] = null

    load url + query + callbackName + "=" + uniqueName
    uniqueName
  setDefaults = (obj) ->
    config = obj
  counter = 0
  head = undefined
  query = undefined
  key = undefined
  window = this
  config = {}
  get: jsonp
  init: setDefaults
)()
