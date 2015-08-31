{BASE_URL} = require('./config')
_ = require 'underscore'
$ = require 'jquery'
path = require 'path'
packagePath = path.dirname(__dirname)
RSpecRunner = require './rspec-runner'

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
    @grammar = atom.grammars.grammarForScopeName(@language)
    @editor.setGrammar(@grammar)

  setUpPanes: (done)->
    @editor = @ensureActiveEditor()
    @setSyntax()
    options =
      split: 'right'
      activatePane: false
      searchAllPanes: true
    path = "neutrino://#{encodeURI(@title)}"
    console.log path
    atom.workspace.open(path, options).then (instructionView) =>
      @instructionView = instructionView
      @instructionView.tutorial = @
      done()

  start: ->
    @setUpPanes =>
      @currentStep ?= 0
      @render()

  goBack: ->

  onSubmit: ->
    @runSpecForStep()

  render: ->
    step = @steps[@currentStep]
    @editor.buffer.setText(step.source)
    @instructionView.setText(step.instruction)

  progress: ->
    if @currentStep is @steps.length - 1
      atom.notifications.addSuccess("You've finished the tutorial!")
    else
      @currentStep += 1
      @render()

  runSpecForStep: ->
    answer = @editor.buffer.getText()
    toRun = "#{answer}\n#{@steps[@currentStep].spec}"
    fileName = "#{@id}-#{new Date().getTime()}.rb"
    filePath = packagePath+"/tmp/#{fileName}"

    runner = new RSpecRunner(toRun, filePath, @)
    runner.run()
