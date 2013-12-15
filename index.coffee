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
    @toolbar.on 'select', @select = (slot) ->
      @currentSlot = slot

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

  # update toolbar with inventory contents
  refresh: () ->
    content = []
    for slot, i in @inventory.array
      if slot?
        itemTexture = @registry.getBlockProps(slot.item).itemTexture
        content.push {icon: @game.materials.texturePath + itemTexture + '.png', label:''+slot.count, id:i}
      else
        content.push {id:i}

    @toolbar.updateContent content
