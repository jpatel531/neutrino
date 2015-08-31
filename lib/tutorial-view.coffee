{ScrollView, View} = require 'atom-space-pen-views'

module.exports =
class NeutrinoView extends ScrollView

  @content: ->
    @div()

  getTitle: ->
    'hello'

  setText: (text)->
    @text(text)

  initialize: (state)->
    super
