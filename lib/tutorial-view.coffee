{ScrollView, View} = require 'atom-space-pen-views'

module.exports =
class NeutrinoView extends ScrollView

  @content: ->
    @div class:'neutrino-tutorial', =>
      @button 'Submit', click: 'onSubmit', class: "btn btn-success inline-block-tight"
      @div class: 'neutrino-instruction'

  getTitle: -> @title

  setText: (text)->
    @find('.neutrino-instruction').text(text)

  onSubmit: ->
    @tutorial.onSubmit()

  initialize: (path)->
    super
    @title = decodeURI(path)
