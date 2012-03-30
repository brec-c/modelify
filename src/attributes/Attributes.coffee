Stateful = require 'stateful'
Resolver = require './Util'

class AttributeFactory

	@resolve: (type) -> Resolver.resolve 'attribute', type
	@createAttribute: (attrType, config) -> new @resolve(attrType)(config)

exports.AttributeFactory = AttributeFactory


class Attribute extends Stateful

	@addState 'empty',
		transitions:
			initial: true
			exit:    'ready, dirty'

	@addState 'ready',
		transitions:
			enter:   'dirty, conflicted, empty' 
			exit:    'dirty'

	@addState 'dirty',
		transitions:
			enter:   'empty, ready, conflicted'
			exit:    'ready, conflicted'

	@addState 'conflicted',
		transitions:
			enter:   'dirty'
			exit:    'dirty, ready'
	
	@define "name",       get: -> @config.name
	@define "owner",      get: -> @config.owner
	@define "readonly",   get: -> if @config.readonly? then @config.readonly else false
	@define "required",   get: -> if @config.isRequired? then @config.isRequired else false
	@define "transient",  get: -> if @config.isTransient? then @config.isTransient else false

	@declare: (type) -> Resolver.registerPlugin 'attribute', type, @

	constructor: (config) ->
		super(config)
		
		@value    = undefined
		@previous = undefined

		# TODO add support for validation
		
		@set(@config.default) if @config.default?

	raw: -> throw new Error("Override raw() on #{this}")	
	get: -> throw new Error("Override get() on #{this}")
	set: (value) ->
		throw new Error "Can't set an attribute that isn't loaded." if @is 'empty'
		throw new Error "Can't set a readonly attribute." if @readonly
		
		isDiff = @_applyValue value
		if isDiff
			@state = 'dirty'
			@_emitChange @value, @previous

	update: (value, metadata) ->
		isDiff = @_applyValue value
		if isDiff
			if @is 'empty' then @state = 'ready'
			else if @is 'dirty' then @state = 'conflicted'

			@_emitChange @value, @previous, metadata
	
	rollback: ->
		return this unless @is "dirty"
		
		@value = @previous # even if undefined I think
		@previous = undefined
		
		@state = 'ready'
		@_emitChange @value, @previous
		
		return this
	
	commit: ->
		return this unless @is "dirty"
		
		@previous = undefined # not sure why we do this here?
		@state = 'ready'
		
		return this
	
	_applyValue: (value) -> throw new Error "Override _applyValue on #{@}"	
	_emitChange: (newValue, oldValue, metadata) -> @emit "change", newValue, oldValue, metadata


exports.Attribute = Attribute

class Property extends Attribute

	constructor: (config) ->
		super
		@type = window[@config.type]

class ModelReference extends Attribute
	constructor: (config) ->
		super
		@type = Resolver.resolve "model", @config.type


class ModelReference extends Attribute
	constructor: (config) ->
		super
		@type = Resolver.resolve "model", @config.type

class ModelCollection extends Attribute





