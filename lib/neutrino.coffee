NeutrinoView = require './neutrino-view'
{CompositeDisposable} = require 'atom'

module.exports = Neutrino =
  neutrinoView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @neutrinoView = new NeutrinoView(state.neutrinoViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @neutrinoView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'neutrino:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @neutrinoView.destroy()

  serialize: ->
    neutrinoViewState: @neutrinoView.serialize()

  toggle: ->
    console.log 'Neutrino was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
