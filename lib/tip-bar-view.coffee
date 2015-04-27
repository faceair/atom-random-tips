request = require 'request'
{Promise} = require 'q'

class TipBarView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('random-tips', 'inline-block')
    @tipLink = document.createElement('a')
    @tipLink.classList.add('inline-block')
    @tipLink.href = '#'
    @appendChild(@tipLink)
    @handleEvents()

  attach: ->
    if atom.config.get('random-tips.displayOnLeft')
      @tile = @statusBar.addLeftTile(priority: 100, item: this)
    else
      @tile = @statusBar.addRightTile(priority: 100, item: this)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  destroy: ->
    @activeItemSubscription?.dispose()
    @tile?.destroy()

  subscribeToActiveTextEditor: ->
    @getRandomTip().done (tip) =>
      @updateRandomTip tip

  updateRandomTip: ({tip, index}) ->
    if @getActiveTextEditor()
      if atom.config.get('random-tips.openTipLink')
        @tipLink.href = "http://tips.hackplan.com/v1/#{index}"
      else
        @tipLink.href = '#'
      @tipLink.textContent = tip
      @style.display = ''
    else
      @style.display = 'none'

  getRandomTip: ->
    Promise (resolve, reject) ->
      request 'http://tips.hackplan.com/?format=json', (err, res, body) ->
        if err
          reject err
        else
          resolve JSON.parse body

module.exports = document.registerElement('random-tips', prototype: TipBarView.prototype)
