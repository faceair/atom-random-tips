tipBar = null

module.exports =
  config:
    displayOnLeft:
      type: 'boolean'
      default: false
    source:
      type: 'string'
      default: 'Random Programming Tips'
      enum: ['Random Programming Tips', '一言（ヒトコト）']

  activate: ->

  deactivate: ->
    tipBar?.destroy()
    tipBar = null

  consumeStatusBar: (statusBar) ->
    TipBarView = require './tip-bar-view'
    tipBar = new TipBarView()
    tipBar.initialize(statusBar)
    tipBar.attach()
