fetch = require 'superfetch'

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
    unless @getActiveTextEditor()
      return @style.display = 'none'

    @getRandomTip()
    .then (tip) =>
      @updateRandomTip tip
    .catch =>
      @updateRandomTip {
        text: 'Tip load error.'
        link: 'https://github.com/faceair/atom-random-tips/issues'
      }

  updateRandomTip: ({text, link}) ->
    unless @getActiveTextEditor()
      return @style.display = 'none'

    @tipLink.href = link
    @tipLink.textContent = text
    @style.display  = ''

  getRandomTip: ->
    referer =
      Referer: 'https://atom.io/packages/random-tips'

    switch atom.config.get('random-tips.source')

      when 'Random Programming Tips'
        fetch.get.header(referer) 'http://tips.hackplan.com/?format=json'
        .then (body) ->
          {tip, index} = JSON.parse body
          return {
            text: tip
            link: "http://tips.hackplan.com/v1/#{index}"
          }

      when '一言（ヒトコト）'
        fetch.get.header(referer) 'http://api.hitokoto.us/rand'
        .then (body) ->
          {id, hitokoto} = JSON.parse body

          return {
            text: hitokoto
            link: "http://hitokoto.us/view/#{id}.html"
          }

module.exports = document.registerElement('random-tips', prototype: TipBarView.prototype)
