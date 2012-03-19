Stateful = require 'stateful'
_        = require 'underscore'

Store    = require './Store'
{AttributeFactory, Property, Reference, Collection} = require './Attributes'

class Model extends Stateful

	@addState 'EMPTY',
		transitions :
			initial : true 
			exit    : 'UPDATING'
	
	@addState 'UPDATING',
		transitions :
			enter   : 'EMPTY'
			exit    : 'NEW, READY'
			
	@addState 'NEW',
		transitions :
			enter   : 'UPDATING'
			exit    : 'SYNCING'
			
	@addState 'READY',
		transitions :
			enter   : 'UPDATING,DIRTY,SYNCING,CONFLICTED,EDITING'
			exit    : 'EDITING'
			
	@addState 'DIRTY',
		transitions :
			enter   : 'CONFLICTED,EDITING'
			exit    : 'READY,SYNCING,CONFLICTED,EDITING'
			
	@addState 'CONFLICTED',
		transitions :
			enter   : 'DIRTY'
			exit    : 'DIRTY,READY,EDITING'
			
	@addState 'EDITING',
		transitions :
			enter   : 'READY,CONFLICTED,DIRTY'
			exit    : 'DIRTY,READY'
			
	@addState 'SYNCING',
		transitions :
			enter   : 'DIRTY'
			exit    : 'READY'

	@buildStateChart()

	#
	# Store proxy methods
	#
	
	@store = new Store type:@

	@get    : -> @store.get.apply @store, arguments
	@find   : -> @store.find.apply @store, arguments
	@create : -> @store.create.apply @store, arguments
	@delete : -> @store.delete.apply @store, arguments


	#
	# Model declarative definitions
	#
	@_attribute: (kind, name, type, config = {}) ->
		@::_schema = {} unless @::_schema?
		@::_schema[name] = _.extend config,
			kind: kind
			name: name
			type: type
			
	@model: (name) -> __storefront.models[name] = this
	@property:   (name, type, config) -> @_attribute('property',   name, type, config)
	@reference:  (name, type, config) -> @_attribute('reference',  name, type, config)
	@collection: (name, type, config) -> @_attribute('collection', name, type, config)


	constructor: (data) ->
		@buildAttributes()
		
		
	buildAttributes: ->
		@attributes = {}
		for name, config of @_schema
			Object.defineProperty this, name,
				get: -> @get(name)
				set: (value) -> @set(name, value)

			attr = AttributeFactory.createAttribute config.kind, _.extend(config, owner: @)
			@attributes[name] = attr

			attr.on "change",      @, "_onAttributeChange"
			attr.on "stateChange", @, "_onAttributeStateChange"
			
				
		
		
		
		
		
		
		
		