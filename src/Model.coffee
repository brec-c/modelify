Stateful = require 'stateful'
_        = require 'underscore'

Store    = require './Store'
{AttributeFactory, Attribute} = require './Attributes'

class Model extends Stateful

	@addState 'EMPTY',
		transitions :
			initial : true 
			exit    : 'UPDATING'
	
	@addState 'UPDATING',
		transitions :
			enter   : 'EMPTY'
			exit    : 'NEW, READY'
			methods : 
				update: (name, value, metadata={}) ->
					if _.isObject name
						metadata = value or {}
						data = name
						data = data.raw() if data instanceof Model

						changes = for attr, value of data
							@updateAttribute attr, value, metadata
					else
						attr = @attributes[name]
						changes = @updateAttribute attr, value, metadata

					@emit 'change', changes

				updateAttribute: (attribute, value, metadata) -> attribute?.update value, metadata

				onAttributeChange: (attribute, newValue, oldValue, metadata) ->
					changeObj =
						property: attribute.name
						newValue: newValue
						oldValue: oldValue
						metadata: metadata

					@emit "change:#{attribute.name}", changeObj

			
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
			methods :
				set: (name, value) ->
					attribute = @attributes[name]
					attribute?.set value

				onAttributeChange: (attribute, newValue, oldValue, metadata) ->
					changeObj =
						property: attribute.name
						newValue: newValue
						oldValue: oldValue
						metadata: metadata

					@emit "change:#{attribute.name}", changeObj

			
	@addState 'SYNCING',
		transitions :
			enter   : 'DIRTY'
			exit    : 'READY'

	@buildStateChart()

	#
	# Store proxy methods
	#
	
	@store = new Store type:@

	@get    : -> @store.get.apply    @store, arguments
	@find   : -> @store.find.apply   @store, arguments
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


	constructor: (data) -> @buildAttributes()
		
	buildAttributes: ->
		@attributes = {}
		for name, config of @_schema
			Object.defineProperty this, name,
				get: -> @get(name)
				set: (value) -> @set(name, value)

			attr = AttributeFactory.createAttribute config.kind, _.extend(config, owner: @)
			@attributes[name] = attr

			attr.on "change",      @, "onAttributeChange"
			attr.on "stateChange", @, "onAttributeStateChange"
			
				
	dispose: -> _.each @attributes, (attr) => attr.dispose()
		
	get: (name) ->
		attr = @attributes[name]
		attr?.get()

