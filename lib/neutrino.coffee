{CompositeDisposable} = require 'atom'
TutorialView = require './tutorial-view'
TutorialListView = require './tutorial-list-view'
uri = 'neutrino://one'
$ = require 'jquery'

BASE_URL = require('./config').BASE_URL

createView = (state) ->
  new TutorialView(state)

openNeutrino = (filePath) ->
  createView(uri: uri) if filePath is uri

module.exports = Neutrino =
  subscriptions: null

  activate: (state) ->

    @subscriptions = new CompositeDisposable
    atom.workspace.addOpener openNeutrino

    @subscriptions.add atom.commands.add 'atom-workspace', 'neutrino:find tutorial': ->
      $.get "#{BASE_URL}/tutorials", (items) ->
        console.log items
        new TutorialListView(items)
