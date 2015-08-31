path = require 'path'
_ = require 'underscore-plus'
cheerio = require 'cheerio'
fs = require 'fs-plus'
Highlights = require 'highlights'
{$} = require 'atom-space-pen-views'
roaster = null # Defer until used

highlighter = null
{resourcePath} = atom.getLoadSettings()
packagePath = path.dirname(__dirname)

scopesByFenceName =
  'sh': 'source.shell'
  'bash': 'source.shell'
  'c': 'source.c'
  'c++': 'source.cpp'
  'cpp': 'source.cpp'
  'coffee': 'source.coffee'
  'coffeescript': 'source.coffee'
  'coffee-script': 'source.coffee'
  'cs': 'source.cs'
  'csharp': 'source.cs'
  'css': 'source.css'
  'scss': 'source.css.scss'
  'sass': 'source.sass'
  'erlang': 'source.erl'
  'go': 'source.go'
  'html': 'text.html.basic'
  'java': 'source.java'
  'js': 'source.js'
  'javascript': 'source.js'
  'json': 'source.json'
  'less': 'source.less'
  'mustache': 'text.html.mustache'
  'objc': 'source.objc'
  'objective-c': 'source.objc'
  'php': 'text.html.php'
  'py': 'source.python'
  'python': 'source.python'
  'rb': 'source.ruby'
  'ruby': 'source.ruby'
  'text': 'text.plain'
  'toml': 'source.toml'
  'xml': 'text.xml'
  'yaml': 'source.yaml'
  'yml': 'source.yaml'

scopeForFenceName: (fenceName) ->
  scopesByFenceName[fenceName] ? "source.#{fenceName}"

exports.toDOMFragment = (text='', filePath, grammar, callback) ->
  render text, filePath, (error, html) ->
    return callback(error) if error?
    template = document.createElement('template')
    template.innerHTML = html
    domFragment = template.content.cloneNode(true)
    # console.log domFragment
    # Default code blocks to be coffee in Literate CoffeeScript files
    # console.log domFragment
    # callback(null, domFragment)
    defaultCodeLanguage = 'coffee' if grammar?.scopeName is 'source.litcoffee'
    convertCodeBlocksToAtomEditors(domFragment, defaultCodeLanguage)
    callback(null, domFragment)

exports.toHTML = (text='', filePath, grammar, callback) ->
  render text, filePath, (error, html) ->
    return callback(error) if error?
    # Default code blocks to be coffee in Literate CoffeeScript files
    defaultCodeLanguage = 'coffee' if grammar?.scopeName is 'source.litcoffee'
    html = tokenizeCodeBlocks(html, defaultCodeLanguage)
    callback(null, html)

render = (text, filePath, callback) ->
  roaster ?= require 'roaster'
  options =
    sanitize: false
    breaks: atom.config.get('markdown-preview.breakOnSingleNewline')

  # Remove the <!doctype> since otherwise marked will escape it
  # https://github.com/chjj/marked/issues/354
  text = text.replace(/^\s*<!doctype(\s+.*)?>\s*/i, '')

  roaster text, options, (error, html) ->
    return callback(error) if error?

    html = sanitize(html)
    html = resolveImagePaths(html, filePath)
    callback(null, html.trim())

sanitize = (html) ->
  o = cheerio.load(html)
  o('script').remove()
  attributesToRemove = [
    'onabort'
    'onblur'
    'onchange'
    'onclick'
    'ondbclick'
    'onerror'
    'onfocus'
    'onkeydown'
    'onkeypress'
    'onkeyup'
    'onload'
    'onmousedown'
    'onmousemove'
    'onmouseover'
    'onmouseout'
    'onmouseup'
    'onreset'
    'onresize'
    'onscroll'
    'onselect'
    'onsubmit'
    'onunload'
  ]
  o('*').removeAttr(attribute) for attribute in attributesToRemove
  o.html()

resolveImagePaths = (html, filePath) ->
  [rootDirectory] = atom.project.relativizePath(filePath)
  o = cheerio.load(html)
  for imgElement in o('img')
    img = o(imgElement)
    if src = img.attr('src')
      continue if src.match(/^(https?|atom):\/\//)
      continue if src.startsWith(process.resourcesPath)
      continue if src.startsWith(resourcePath)
      continue if src.startsWith(packagePath)

      if src[0] is '/'
        unless fs.isFileSync(src)
          if rootDirectory
            img.attr('src', path.join(rootDirectory, src.substring(1)))
      else
        img.attr('src', path.resolve(path.dirname(filePath), src))

  o.html()

convertCodeBlocksToAtomEditors = (domFragment, defaultLanguage='text') ->
  if fontFamily = atom.config.get('editor.fontFamily')
    for codeElement in domFragment.querySelectorAll('code')
      codeElement.style.fontFamily = fontFamily
  for preElement in domFragment.querySelectorAll('pre')
    codeBlock = preElement.firstElementChild ? preElement
    fenceName = codeBlock.getAttribute('class')?.replace(/^lang-/, '') ? defaultLanguage
    console.log fenceName
    editorElement = document.createElement('atom-text-editor')
    editorElement.setAttributeNode(document.createAttribute('gutter-hidden'))
    editorElement.removeAttribute('tabindex') # make read-only

    preElement.parentNode.insertBefore(editorElement, preElement)
    preElement.remove()

    editor = editorElement.getModel()
    # remove the default selection of a line in each editor
    editor.getDecorations(class: 'cursor-line', type: 'line')[0].destroy()
    editor.setText(codeBlock.textContent.trim())
    console.log 'here'
    # console.log scopeForFenceName
    # grammar = atom.grammars.grammarForScopeName(scopeForFenceName(fenceName))
    # console.log grammar
    # if grammar
      # console.log grammar
    editor.setGrammar(atom.grammars.grammarForScopeName "source.#{fenceName}")
      # console.log grammar
    # console.log 'ello'
  domFragment

tokenizeCodeBlocks = (html, defaultLanguage='text') ->
  o = cheerio.load(html)

  if fontFamily = atom.config.get('editor.fontFamily')
    o('code').css('font-family', fontFamily)

  for preElement in o("pre")
    codeBlock = o(preElement).children().first()
    fenceName = codeBlock.attr('class')?.replace(/^lang-/, '') ? defaultLanguage

    highlighter ?= new Highlights(registry: atom.grammars)
    highlightedHtml = highlighter.highlightSync
      fileContents: codeBlock.text()
      scopeName: scopeForFenceName(fenceName)

    highlightedBlock = o(highlightedHtml)
    # The `editor` class messes things up as `.editor` has absolutely positioned lines
    highlightedBlock.removeClass('editor').addClass("lang-#{fenceName}")

    o(preElement).replaceWith(highlightedBlock)

  o.html()
