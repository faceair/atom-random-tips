tipBar = null

module.exports =
  config:
    openTipLink:
      type: 'boolean'
      default: true

  activate: ->

  deactivate: ->
    tipBar?.destroy()
    tipBar = null

  consumeStatusBar: (statusBar) ->
    TipBarView = require './tip-bar-view'
    tipBar = new TipBarView()
    tipBar.initialize(statusBar)
    tipBar.attach()
