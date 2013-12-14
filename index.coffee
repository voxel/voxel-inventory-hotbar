# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

EventEmitter = (require 'events').EventEmitter

module.exports = (game, opts) ->
  return new InventoryToolbar(game, opts)

class InventoryTool extends EventEmitter
  constructor: (game, opts) ->
    @enable()

  enable: () ->
  
  disable: () ->

