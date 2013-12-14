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
  
  disable: () ->
    @toolbar.removeListener 'select', @select

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
        # TODO: configurable item textures (for now only uses block top)
        blockTextures = @registry.getBlockProps(slot.item).texture
        itemTexture = if typeof blockTextures == 'string' then blockTextures else blockTextures[0]

        content.push {icon: @game.materials.texturePath + itemTexture + '.png', label:''+slot.count, id:i}
      else
        content.push {id:i}

    @toolbar.updateContent content
