BASE_URL = require('./config').BASE_URL
_ = require 'underscore'
$ = require 'jquery'
module.exports =
class Tutorial

  constructor: (obj)->
    {@id, @title} = obj
    @_fetch()

  _fetch: ->
    $.get "#{BASE_URL}/tutorials/#{@id}", (tutorial) =>
      _.extend(@, tutorial)
      @start()

  ensureActiveEditor: ->
    editor = atom.workspace.getActiveTextEditor()
    atom.notifications.addError("plz open an editor") unless editor
    editor

  setSyntax: ->
    console.log @language
    grammar = atom.grammars.grammarForScopeName(@language)
    console.log grammar
    @editor.setGrammar(grammar)

  setUpPanes: (done)->
    @editor = @ensureActiveEditor()
    @setSyntax()
    options =
      split: 'right'
      activatePane: false
      searchAllPanes: true
    atom.workspace.open("neutrino://one", options).then (instructionView) =>
      @instructionView = instructionView
      done()

  start: ->
    @setUpPanes =>
      @render(1)

  render: (step)->
    step = @steps[step]
    @editor.buffer.setText(step.source)
    @instructionView.setText(step.instruction)

  runSpecForStep: (step) ->
