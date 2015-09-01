{BASE_URL} = require('./config')
_ = require 'underscore'
$ = require 'jquery'
path = require 'path'
packagePath = path.dirname(__dirname)
RSpecRunner = require './rspec-runner'

SourceEditor = require './source-editor'

module.exports =
class Tutorial

  currentStep: 1
  sourceEditors: []

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

  setUpInstruction: (done)->
    options =
      split: 'right'
      activatePane: false
      searchAllPanes: true
    path = "neutrino://#{encodeURI(@title)}"
    atom.workspace.open(path, options).then (instructionView) =>
      @instructionView = instructionView
      @instructionView.tutorial = @
      done()

  start: ->
    @setUpInstruction => @render()

  goBack: ->

  onSubmit: ->
    @runSpecForStep()

  render: ->
    step = @steps[@currentStep]
    renderedTitles = _.pluck(@sourceEditors, 'title')
    unrenderedFiles = _.reject step.source, (source) =>
      _.contains(renderedTitles, source.title)
    _.each unrenderedFiles, (source) =>
      atom.workspace.open(null, split: 'left').then (editor) =>
        sourceEditor = new SourceEditor(editor, source.code, source.title, source.language)
        @sourceEditors.push sourceEditor
    @instructionView.setText(step.instruction)

  progress: ->
    if @currentStep is @steps.length - 1
      atom.notifications.addSuccess("You've finished the tutorial!")
    else
      @currentStep += 1
      @render()

  runSpecForStep: ->
    allText = _.map @sourceEditors, (source) =>
      source.editor.buffer.getText()
    answer = allText.join("\n")
    toRun = "#{answer}\n#{@steps[@currentStep].spec}"
    fileName = "#{@id}-#{new Date().getTime()}.rb"
    filePath = packagePath+"/tmp/#{fileName}"

    runner = new RSpecRunner(toRun, filePath, @)
    runner.run()
