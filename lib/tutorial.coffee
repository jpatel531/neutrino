{BASE_URL} = require('./config')
_ = require 'underscore'
$ = require 'jquery'
ChildProcess  = require 'child_process'
fs = require 'fs'
path = require 'path'
packagePath = path.dirname(__dirname)

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

  onData: (data) ->
    result = JSON.parse data.toString()
    console.log result
    if result.summary.failure_count is 0
      atom.notifications.addSuccess("Success!")
      setTimeout((=> @progress()),1000)
    else
      failures = _.filter(result.examples, {status: "failed"})
      _.each failures, (failure) ->
        atom.notifications.addError("#{failure.full_description}\n#{failure.exception.message}")

  onErr: (data) ->
    error = JSON.parse data.toString()
    atom.notifications.addError(error)

  runSpecForStep: ->
    answer = @editor.buffer.getText()
    toRun = "#{answer}\n#{@steps[@currentStep].spec}"
    fileName = "#{@id}-#{new Date().getTime()}.rb"
    path = packagePath+"/tmp/#{fileName}"
    fs.writeFileSync(path, toRun)
    command = "rspec -fj #{path}"

    spawn = ChildProcess.spawn
    terminal = spawn("bash", ["-l"])

    terminal.on 'close', ->
      ChildProcess.exec("rm #{path}")

    terminal.stdout.on 'data', (data)=> @onData(data)
    terminal.stderr.on 'data', (data) => @onErr(data)

    terminal.stdin.write("#{command}\n")
    terminal.stdin.write("exit\n")
