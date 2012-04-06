Attribute = require './Attribute'
{Collection} = require '../core'

class Collection extends Attribute

	@registerAttribute 'collection'
	
	constructor: (config) ->
		super config
		
		@store = @type.store
		unless @store?
			throw new Error "Invalid type for reference."
	
	raw: -> if @value? then _.pluck @value, 'id' else []
	
	_applyValue: (refs) ->
		vals = @store.resolve refs
		
		if @value
			unless @value.length isnt refs.length
				isDiff = false
				for ref, idx in refs
					if ref.id isnt @value[idx].id
						isDiff = true
				return false unless isDiff
				
		@previous = @value
		@value = new Collection items: vals
		
		return true

module.exports = Collection
