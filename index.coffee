# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

EventEmitter = (require 'events').EventEmitter
InventoryWindow = require 'inventory-window'

module.exports = (game, opts) ->
  new InventoryHotbar(game, opts)

class InventoryHotbar extends EventEmitter
  constructor: (@game, opts) ->
    opts ?= {}

    @inventory = opts.inventory ? throw 'voxel-inventory-toolbar requires "inventory" option set to inventory instance'
    @registry = opts.registry ? throw 'voxel-inventory-toolbar requires "registry" option set to voxel-registry instance'

    windowOpts = opts.windowOpts ? {}
    windowOpts.inventory ?= @inventory 
    windowOpts.inventorySize ?= opts.inventorySize ? @inventory.size()
    windowOpts.width ?= opts.width ? windowOpts.inventorySize   # default to one row
    windowOpts.getTexture ?= opts.getTexture ? (itemPile) =>
      game.materials.texturePath + @registry.getItemProps(itemPile.item).itemTexture + '.png'
    @inventoryWindow = new InventoryWindow windowOpts
    container = @inventoryWindow.createContainer()

    container.style.position = 'fixed'
    container.style.bottom = '0px'
    container.style.zIndex = 5
    container.style.right = '33%'
    container.style.left = '33%'
    document.body.appendChild container

    @currentSlot = 0
    @enable()

  enable: () ->
    @inventoryWindow.container.style.visibility = ''
  
  disable: () ->
    @inventoryWindow.container.style.visibility = 'hidden'

  give: (itemPile) -> @inventory.give itemPile
  take: (itemPile) -> @inventory.take itemPile

  # take some items from the pile the player is currently holding
  takeHeld: (count=1) -> @inventory.takeAt @currentSlot, count

  # get the pile of items the player is currently holding
  held: () ->
    @inventory.get @currentSlot

  refresh: () ->
    @inventoryWindow.refresh()
