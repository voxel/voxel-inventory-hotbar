# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

EventEmitter = (require 'events').EventEmitter
InventoryWindow = require 'inventory-window'
ever = require 'ever'

module.exports = (game, opts) ->
  if game.isClient
    new InventoryHotbarClient game, opts
  else
    new InventoryHotbarCommon game, opts

module.exports.pluginInfo =
  loadAfter: ['voxel-carry', 'voxel-registry']

class InventoryHotbarCommon extends EventEmitter
  constructor: (@game, opts) ->
    opts ?= {}

    @inventory = game.plugins?.get('voxel-carry')?.inventory ? opts.inventory ? throw 'voxel-inventory-hotbar requires "voxel-carry" plugin or "inventory" option set to inventory instance'
    @selectedIndex = 0

  enable: () ->

  disable: () ->

  give: (itemPile) -> @inventory.give itemPile
  take: (itemPile) -> @inventory.take itemPile

  # take some items from the pile the player is currently holding
  takeHeld: (count=1) -> @inventory.takeAt @selectedIndex, count

  # get the pile of items the player is currently holding
  held: () ->
    @inventory.get @selectedIndex

class InventoryHotbarClient extends InventoryHotbarCommon
  constructor: (@game, opts) ->
    super @game, opts

    @wheelEnable = opts.wheelEnable ? false # enable scroll wheel to change slots?
    @wheelScale = opts.wheelScale ? 1.0  # mouse wheel scrolling sensitivity

    registry = game.plugins?.get('voxel-registry')
    windowOpts = opts.windowOpts ? {}
    windowOpts.registry ?= registry if registry
    windowOpts.inventory ?= @inventory
    windowOpts.inventorySize ?= opts.inventorySize ? @inventory.size()
    windowOpts.width ?= opts.width ? windowOpts.inventorySize   # default to one row
    @inventoryWindow = new InventoryWindow windowOpts
    @inventoryWindow.selectedIndex = 0

    container = @inventoryWindow.createContainer()

    # center at bottom of screen
    container.style.position = 'fixed'
    container.style.bottom = '0px'
    container.style.zIndex = 5
    container.style.right = '33%'
    container.style.left = '33%'
    document.body.appendChild container

    @enable()

  enable: () ->
    @inventoryWindow.container.style.visibility = ''
    @onSlots = {}

    if @wheelEnable
      ever(document.body).on 'mousewheel', @mousewheel = (ev) => # TODO: also DOMScrollWheel for Firefox
        console.log 'mousewheel',ev
        delta = ev.wheelDelta
        delta /= @wheelScale
        delta = Math.floor delta
        @selectedIndex += delta
        @selectedIndex = @selectedIndex %% @inventoryWindow.width
        console.log @selectedIndex
        @inventoryWindow.setSelected @selectedIndex

    if @game.buttons.bindings? # kb-bindings available, configurable bindings
      [0..9].forEach (slot) =>
        # key numeric 1 is slot 0th, 2 is 1st, .. 0 is last
        if slot == 9
          key = '0'
        else
          key = ''+(slot + 1)

        # human-readable keybinding name (1-based)
        slotName = 'slot' + (slot + 1)

        @game.buttons.bindings[key] = slotName
        @game.buttons.down.on slotName, @onSlots[key] = () =>
          @selectedIndex = slot
          @inventoryWindow.setSelected @selectedIndex

    else  # fallback kb-controls support
      @keydown = (ev) =>   # note: doesn't disable when gui open - above does
        if '0'.charCodeAt(0) <= ev.keyCode <= '9'.charCodeAt(0)
          slot = ev.keyCode - '0'.charCodeAt(0)
          if slot == 0
            slot = 10
          slot -= 1
          @selectedIndex = slot
          @inventoryWindow.setSelected @selectedIndex
      ever(document.body).on 'keydown', @keydown

    super()
  
  disable: () ->
    @inventoryWindow.container.style.visibility = 'hidden'

    ever(document.body).removeListener 'mousewheel', @mousewheel if @mousewheel?

    if @game.buttons.bindings?
      for key in [1..10]
        delete @game.buttons.bindings[key - 1]
        @game.buttons.down.removeListener 'slot' + key, @onSlots[key - 1]
    else
      ever(document.body).removeListener 'keydown', @keydown

    super()

  refresh: () ->
    @inventoryWindow.refresh()


