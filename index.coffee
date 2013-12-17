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

  give: (itemPile) ->
    ret = @inventory.give itemPile
    @refresh()
    ret

  take: (itemPile) ->
    ret = @inventory.take itemPile
    @refresh()
    ret

  # take some items from the pile the player is currently holding
  takeHeld: (count=1) ->
    ret = @inventory.takeAt @currentSlot, count
    @refresh()
    ret

  # get the pile of items the player is currently holding
  held: () ->
    @inventory.slot @currentSlot

  # update toolbar with inventory contents
  refresh: () ->
    content = []
    for slot, i in @inventory.array
      if slot?
        itemTexture = @registry.getItemProps(slot.item).itemTexture

        # label is count if finite, or name (for creative mode) if infinite
        if slot.count == Infinity
          label = slot.item
        else if slot.count == 1
          label = ''
        else
          label = ''+slot.count

        content.push {icon: @game.materials.texturePath + itemTexture + '.png', label:label, id:i}
      else
        content.push {id:i}

    @toolbar.updateContent content
