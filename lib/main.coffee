{CompositeDisposable} = require 'atom'
request = require 'request'
{View} = require 'space-pen'
{Promise} = require 'q'

class TipBar extends View
  @content: ->
    @a href: '#', class: 'inline-block', click: 'onClick', 'Loading...'

  initialize: (statusBar, {@openTipLink, @package}) ->
    @tile = statusBar.addLeftTile
      priority: 100
      item: @

  setTip: (tipObj) ->
    @text tipObj.tip
    if @openTipLink
      @attr 'href', "http://tips.hackplan.com/v1/#{tipObj.index}"

  onClick: ->
    @refreshTip()

  destroy: ->
    @tile.destroy()

  refreshTip: ->
    @tipsAPI().done (tipObj) =>
      @setTip tipObj

  tipsAPI: ->
    Promise (resolve, reject) =>
      request 'http://tips.hackplan.com/?format=json',
        headers:
          'User-Agent': "#{@package.name}/#{@package.version}"
      , (err, res, body) ->
        if err
          reject err
        else
          resolve JSON.parse body

module.exports =
  package: require '../package'

  config:
    openTipLink:
      type: 'boolean'
      default: true

  serialize: ->

  activate: ->
    @disposables = new CompositeDisposable()

    @disposables.add atom.commands.add 'atom-workspace',
      'random-tips:refreshTip': => @refreshTip()

    @refreshTip()

  refreshTip: ->
    @tipBar?.refreshTip()

  deactivate: ->
    @disposables.dispose()
    @tipBar.destroy()

  consumeStatusBar: (statusBar) ->
    @tipBar = new TipBar statusBar,
      openTipLink: atom.config.get('random-tips.openTipLink')
      package: @package
    @refreshTip()
