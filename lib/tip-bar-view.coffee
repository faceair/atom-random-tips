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
    if @getActiveTextEditor()
      @getRandomTip().done (tip) =>
        @updateRandomTip tip
    else
      @style.display = 'none'

  updateRandomTip: ({text, link}) ->
    @tipLink.href = link
    @tipLink.textContent = text
    @style.display = ''

  getRandomTip: ->
    Promise (resolve, reject) ->
      switch atom.config.get('random-tips.source')
        when 'Random Programming Tips'
          request 'http://tips.hackplan.com/?format=json', (err, res, body) ->
            if err
              resolve {
                text: 'Tip load error.'
                link: '#'
              }
            else
              {tip, index} = JSON.parse body
              resolve {
                text: tip
                link: "http://tips.hackplan.com/v1/#{index}"
              }

        when '一言（ヒトコト）'
          request 'http://api.hitokoto.us/rand', (err, res, body) ->
            if err
              resolve {
                text: 'Tip load error.'
                link: '#'
              }
            else
              {id, hitokoto} = JSON.parse body
              resolve {
                text: hitokoto
                link: "http://hitokoto.us/view/#{id}.html"
              }

        else
          resolve()

module.exports = document.registerElement('random-tips', prototype: TipBarView.prototype)
