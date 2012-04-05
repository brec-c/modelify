Base                          = require './Base'
Store                         = require './Store'
{AttributeFactory, Attribute} = require './attributes'
Util                          = require './Util'
_                             = require 'underscore'

class Model extends Base
	
	@addState 'UPDATING',
		transitions :
			initial : true
			enter   : 'READY, DIRTY, CONFLICTED'
			exit    : 'NEW, READY, DIRTY, CONFLICTED'
		methods     : 
			update: (name, value, metadata={}) ->
				if _.isObject name
					metadata = value or {}
					data = name
					data = data.raw() if data instanceof Model

					changes = for name, value of data
						attribute = @attributes[name]
						@updateAttribute attribute, value, metadata
				else
					attribute = @attributes[name]
					changes = @updateAttribute attribute, value, metadata

				@emit 'change', changes

			updateAttribute: (attribute, value, metadata) -> attribute?.update value, metadata

			onAttributeChange: (attribute, newValue, oldValue, metadata) ->
				changeObj =
					property: attribute.name
					newValue: newValue
					oldValue: oldValue
					metadata: metadata

				@emit "change:#{attribute.name}", changeObj

			onAttributeStateChange: (attr) ->
				for name, attribute of @attributes
					if attribute.require and attribute.is 'NOT_SET' then return
				@state = 'READY'
			
	@addState 'NEW',
		transitions :
			enter   : 'UPDATING'
			exit    : 'SYNCING'
			
	@addState 'READY',
		transitions :
			enter   : 'UPDATING,DIRTY,SYNCING,CONFLICTED,EDITING'
			exit    : 'EDITING, UPDATING'
			
	@addState 'DIRTY',
		transitions :
			enter   : 'CONFLICTED,EDITING,UPDATING'
			exit    : 'READY,SYNCING,CONFLICTED,EDITING,UPDATING'
			
	@addState 'CONFLICTED',
		transitions :
			enter   : 'DIRTY,UPDATING'
			exit    : 'DIRTY,READY,EDITING,UPDATING'
			
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

	# do we want models to be aware of this?
	@addState 'SYNCING',
		transitions :
			enter   : 'DIRTY, NEW'
			exit    : 'READY'

	@buildStateChart()

	#
	# Store proxy methods
	#
	
	@registerModelType: -> 
		@::store = new Store type:@
		console.log  "store exists: #{@::store?}"

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
			
	@property:   (name, type, config) -> @_attribute('property',   name, type, config)
	@reference:  (name, type, config) -> @_attribute('reference',  name, type, config)
	@collection: (name, type, config) -> @_attribute('collection', name, type, config)

	Util.registerPlugin('model', @constructor.name, @)

	constructor: (data) ->
		super

		console.log  "store exists: #{@store?} and type is #{@store.type.name}"

		@buildAttributes()
		@store.registerModel @

		@update data if data

	buildAttributes: ->
		@attributes = {}
		
		unless @_schema['id']?
			@_schema['id'] = kind: 'property', name: 'id', type: 'Number'
		
		for name, config of @_schema
			console.log "building attribute for #{name}"
			Object.defineProperty this, name,
				get: -> @get(name)
				set: (value) -> @set(name, value)

			attr = AttributeFactory.createAttribute config.kind, _.extend(config, owner: @)
			@attributes[name] = attr

			attr.on "change",      => @onAttributeChange
			attr.on "stateChange", => @onAttributeStateChange

	dispose: -> _.each @attributes, (attr) => attr.dispose()
		
	get: (name) ->
		attr = @attributes[name]
		attr?.get()
		
	toString: ->
		sup = super
		if @attributes['id']?.is 'SET' then sup += "[#{@id}]"
		return sup
		
	toJSON: (attributes=@attributes)->
		values = {}
		for name,attr of @attributes
			values[attr.name] = attr.raw()
		return values

module.exports = Model
