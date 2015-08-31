ChildProcess  = require 'child_process'
fs = require 'fs'
_ = require 'underscore'

module.exports =
class RSpecRunner

  constructor: (@script, @path, @tutorial) ->

  onData: (data) ->
    result = JSON.parse data.toString()
    if result.summary.failure_count is 0
      atom.notifications.addSuccess("Success!")
      setTimeout((=> @tutorial.progress()),1000)
    else
      failures = _.filter(result.examples, {status: "failed"})
      _.each failures, (failure) ->
        atom.notifications.addError("#{failure.full_description}\n#{failure.exception.message}")

  onErr: (data) ->
    error = JSON.parse data.toString()
    atom.notifications.addError(error)

  run: ->
    fs.writeFileSync(@path, @script)
    command = "rspec -fj #{@path}"

    spawn = ChildProcess.spawn
    terminal = spawn("bash", ["-l"])

    terminal.on 'close', ->
      ChildProcess.exec("rm #{@path}")

    terminal.stdout.on 'data', (data) => @onData(data)
    terminal.stderr.on 'data', (data) => @onErr(data)

    terminal.stdin.write("#{command}\n")
    terminal.stdin.write("exit\n")
