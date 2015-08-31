{ScrollView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

renderer = require './md-renderer'

module.exports =
class NeutrinoView extends ScrollView

  @content: ->
    @div class:'neutrino-tutorial', =>
      @button 'Submit', click: 'onSubmit', class: "btn btn-success inline-block-tight"
      @div class: 'neutrino-instruction'

  getTitle: -> @title

  setText: (text)->
    renderer.toDOMFragment text, null, null, (error, domFragment) =>
      console.log error
      console.log domFragment
      if error then throw error
      @find('.neutrino-instruction').html(domFragment)

  onSubmit: ->
    @tutorial.onSubmit()

  initialize: (path)->
    super
    @title = decodeURI(path)
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add atom.views.getView(atom.workspace), 'neutrino:submit': => @onSubmit()
