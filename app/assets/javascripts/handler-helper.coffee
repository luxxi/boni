class RestaurantStorage

  OBJECT_NAME: 'restaurants_cache'

  constructor: ->
    @DATA_NAME = "#{@OBJECT_NAME}_data"
    @VERSION_NAME = "#{@OBJECT_NAME}_version"

  getRestaurants: ->
    try
      JSON.parse localStorage[@DATA_NAME]
    catch e
      []

  addRestaurants: (restaurantsObj) ->
    try
      escape = (string) ->
        string.replace(/\\n/g, "\\n")
          .replace(/\\'/g, "\\'")
          .replace(/\\"/g, '\\"')
          .replace(/\\&/g, "\\&")
          .replace(/\\r/g, "\\r")
          .replace(/\\t/g, "\\t")
          .replace(/\\b/g, "\\b")
          .replace(/\\f/g, "\\f")
      setTimeout =>
        localStorage[@DATA_NAME] = escape JSON.stringify restaurantsObj
      , 1
      true
    catch e
      false

  isUpToDate: (timestamp) ->
    JSON.parse(localStorage[@VERSION_NAME] or 0) is timestamp


class HandlerHelper

  RESTAURANTS_URL: '/restaurants'
  VESION_URL: '/version'

  constructor: (@center) ->
    @restaurantStorage = new RestaurantStorage()
    @version = 0
    @versionRequest = $.getJSON @VESION_URL, (data) -> @version = data.version

  getCenter: => @center
  setCenter: (@center) =>

  AddMarkers: (handler, callback) ->
    makeInfowindow = (obj) ->
      lat: obj.lat
      lng: obj.lng
      infowindow: """
      <p><b>#{obj.name}</b></p>
      <p>#{obj.address}, #{obj.city}</p>
      <p>cena doplačila: #{obj.price} &#8364;</p>"""

    makeMarkers = (data) ->
      markers = handler.addMarkers data.map makeInfowindow
      handler.bounds.extendWith markers
      callback() if callback

    loadData = (data) =>
      @version = data.version if data
      if not @restaurantStorage.isUpToDate @version
        console.log 'load from server'
        $.getJSON @RESTAURANTS_URL, (data) =>
          @restaurantStorage.addRestaurants data
          makeMarkers data
      else
        console.log 'load from cache'
        makeMarkers @restaurantStorage.getRestaurants()

    if @version then loadData() else @versionRequest.done loadData

window.HandlerHelper = HandlerHelper
