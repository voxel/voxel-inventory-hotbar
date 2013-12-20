# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

EventEmitter = (require 'events').EventEmitter

module.exports = (game, opts) ->
  new InventoryToolbar(game, opts)

class InventoryToolbar extends EventEmitter
  constructor: (@game, opts) ->
    opts ?= {}

    @toolbar = opts.toolbar ? throw 'voxel-inventory-toolbar requires "toolbar" option set to toolbar instance'
    @inventory = opts.inventory ? throw 'voxel-inventory-toolbar requires "inventory" option set to inventory instance'
    @registry = opts.registry ? throw 'voxel-inventory-toolbar requires "registry" option set to voxel-registry instance'

    @inventorySize = opts.inventorySize ? @inventory.size()

    @inventory.on 'changed', () => @refresh()
    @currentSlot = 0

    @enable()

  enable: () ->
    @toolbar.on 'select', @select = (slot) =>
      @currentSlot = slot

    @refresh()
    @toolbar.el.style.visibility = ''
  
  disable: () ->
    @toolbar.removeListener 'select', @select
    @toolbar.el.style.visibility = 'hidden'  # TODO: option to "disable" in toolbar module, unbind events (num keys), hide..

  give: (itemPile) -> @inventory.give itemPile
  take: (itemPile) -> @inventory.take itemPile

  # take some items from the pile the player is currently holding
  takeHeld: (count=1) -> @inventory.takeAt @currentSlot, count

  # get the pile of items the player is currently holding
  held: () ->
    @inventory.get @currentSlot

  # update toolbar with inventory contents
  refresh: () ->
    content = []
    for i in [0...@inventorySize]
      itemPile = @inventory.get(i)
      if itemPile?
        itemTexture = @registry.getItemProps(itemPile.item).itemTexture

        # label is count if finite, or name (for creative mode) if infinite
        if itemPile.count == Infinity
          label = itemPile.item
        else if itemPile.count == 1
          label = ''
        else
          label = ''+itemPile.count

        content.push {icon: @game.materials.texturePath + itemTexture + '.png', label:label, id:i}
      else
        content.push {id:i}

    @toolbar.updateContent content
