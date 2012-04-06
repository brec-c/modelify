{Base}         = require '../core'
TypeRegister   = require '../TypeRegister'

class Attribute extends Base

	@addState 'NOT_SET',
		transitions:
			initial: true
			exit:    'SET'#, DIRTY'
		methods:
			set: (value) ->	throw new Error "Can't set an attribute that isn't loaded."

	@addState 'SET',
		transitions:
			enter:   'DIRTY, CONFLICTED, NOT_SET'
			exit:    'DIRTY'

	@addState 'DIRTY',
		transitions:
			enter:   'SET, CONFLICTED' #NOT_SET
			exit:    'SET, CONFLICTED'
		methods: 
			rollback: ->
				@value = @previous # even if undefined I think
				@previous = undefined

				@state = 'SET'
				@_emitChange @value, @previous

				return this
			
			commit: ->
				@previous = undefined # not sure why we do this here?
				@state = 'SET'

				return this

	@addState 'CONFLICTED',
		transitions:
			enter:   'DIRTY'
			exit:    'DIRTY, SET'
		methods: 
			rollback: ->
				@value = @previous # even if undefined I think
				@previous = undefined

				@state = 'SET'
				@_emitChange @value, @previous

				return this

	@buildStateChart()
	
	@define "name",       get: -> @config.name
	@define "owner",      get: -> @config.owner
	@define "readonly",   get: -> if @config.readonly? then @config.readonly else false
	@define "required",   get: -> if @config.isRequired? then @config.isRequired else false
	@define "transient",  get: -> if @config.isTransient? then @config.isTransient else false

	@define 'typeString', get: -> @config.type
	@define 'type',
		get: -> 
			if TypeRegister.isModel(@config.type)
				TypeRegister.getModel @config.type 
			else 
				TypeRegister.resolve @config.type

	@registerAttribute: (name) -> TypeRegister.addAttribute name, @

	constructor: (config) ->
		super(config)
		
		@value    = undefined
		@previous = undefined

		# TODO add support for validation
		
		@set(@config.default) if @config.default?

	raw: -> @value
	get: -> @value
	set: (value) ->
		throw new Error "Can't set a readonly attribute." if @readonly
		
		isDiff = @_applyValue value
		if isDiff
			@state = 'DIRTY'
			@_emitChange @value, @previous

	update: (value, metadata) ->
		isDiff = @_applyValue value
		if isDiff
			if @is 'NOT_SET' then @state = 'SET'
			else if @is 'DIRTY' then @state = 'CONFLICTED'

			@_emitChange @value, @previous, metadata
			
	rollback: -> @
	commit: -> @
	_applyValue: (value) -> throw new Error "Override _applyValue on #{@}"	
	_emitChange: (newValue, oldValue, metadata) -> @emit "change", newValue, oldValue, metadata


module.exports = Attribute
