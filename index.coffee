# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

EventEmitter = (require 'events').EventEmitter
InventoryWindow = require 'inventory-window'
ever = require 'ever'

module.exports = (game, opts) ->
  new InventoryHotbar(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-carry', 'voxel-registry']

class InventoryHotbar extends EventEmitter
  constructor: (@game, opts) ->
    opts ?= {}

    @inventory = game.plugins?.get('voxel-carry')?.inventory ? opts.inventory ? throw 'voxel-inventory-hotbar requires "voxel-carry" plugin or "inventory" option set to inventory instance'
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

    @keydown = (ev) =>   # TODO: disable whem gui open?
      if '0'.charCodeAt(0) <= ev.keyCode <= '9'.charCodeAt(0)
        slot = ev.keyCode - '0'.charCodeAt(0) 
        if slot == 0
          slot = 10
        slot -= 1
        @inventoryWindow.setSelected(slot)
    ever(document.body).on 'keydown', @keydown
  
  disable: () ->
    @inventoryWindow.container.style.visibility = 'hidden'
    ever(document.body).removeListener 'keydown', @keydown

  give: (itemPile) -> @inventory.give itemPile
  take: (itemPile) -> @inventory.take itemPile

  # take some items from the pile the player is currently holding
  takeHeld: (count=1) -> @inventory.takeAt @inventoryWindow.selectedIndex, count

  # get the pile of items the player is currently holding
  held: () ->
    @inventory.get @inventoryWindow.selectedIndex

  refresh: () ->
    @inventoryWindow.refresh()
