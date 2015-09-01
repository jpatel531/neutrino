module.exports =
class SourceEditor

  constructor: (@editor, @contents, @title, @language) ->
    @editor.buffer.setText(@contents)
    console.log 'hello'
    @setSyntax()

  setSyntax: ->
    scopeName = "source.#{@language}"
    console.log scopeName
    @grammar = atom.grammars.grammarForScopeName(scopeName)
    @editor.setGrammar(@grammar)
