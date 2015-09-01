{ScrollView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

renderer = require './md-renderer'

module.exports =
class NeutrinoView extends ScrollView

  @content: ->
    @div class:'neutrino-tutorial', =>
      @button 'Submit', click: 'onSubmit', class: "btn btn-lg btn-success inline-block-tight"
      @button 'Go Back', click: 'goBack', class: "btn btn-lg btn-warning inline-block-tight"
      @div class: 'neutrino-instruction'

  getTitle: -> @title

  setText: (text)->
    renderer.toDOMFragment text, null, null, (error, domFragment) =>
      if error then throw error
      @find('.neutrino-instruction').html(domFragment)

  goBack: ->
    @tutorial.goBack()

  onSubmit: ->
    @tutorial.onSubmit()

  initialize: (path)->
    super
    @title = decodeURI(path)
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add atom.views.getView(atom.workspace), 'neutrino:submit': => @onSubmit()
