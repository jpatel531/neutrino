{CompositeDisposable} = require 'atom'
TutorialView = require './tutorial-view'
TutorialListView = require './tutorial-list-view'
$ = require 'jquery'
url = require 'url'

scheme = 'neutrino:'

{BASE_URL} = require('./config')

createView = (state) ->
  new TutorialView(state)

openNeutrino = (filePath) ->
  {protocol, hostname} = url.parse(filePath)
  return unless protocol is scheme
  createView(hostname)

module.exports = Neutrino =
  subscriptions: null

  activate: (state) ->

    @subscriptions = new CompositeDisposable
    atom.workspace.addOpener openNeutrino

    @subscriptions.add atom.commands.add 'atom-workspace', 'neutrino:find tutorial': ->
      $.get "#{BASE_URL}/tutorials", (items) ->
        new TutorialListView(items)
