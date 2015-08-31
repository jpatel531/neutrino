{ScrollView, View} = require 'atom-space-pen-views'

module.exports =
class NeutrinoView extends ScrollView

  @content: ->
    @div =>
      @button 'Submit', click: 'onSubmit'
      @div class: 'neutrino-instruction'

  getTitle: ->
    'hello'

  setText: (text)->
    @find('.neutrino-instruction').text(text)

  onSubmit: ->
    @tutorial.onSubmit()

  initialize: (state)->
    super
