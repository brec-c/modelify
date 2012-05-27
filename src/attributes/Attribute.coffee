{Base}         = require '../core'
TypeRegister   = require '../TypeRegister'

class Attribute extends Base

# ---------------------------------------------------------------------------------------

	@StateChart
		Unloaded: 
			transitions: [
				destination: 'Loaded'
				action: 'update'
			]
			methods:
				update: (value, metadata) ->
					isDiff = @_applyValue value
					if isDiff then @_emitChange @value, @previous, metadata
					return {name: @name, value: @value, previous: @previous}
			paths: 
				Loaded:
					transitions: [
						destination: 'Dirty'
						action: 'set'
					]
					methods: 
						set: (value) ->
							throw new Error "Can't set a readonly attribute." if @readonly
				
							isDiff = @_applyValue value
							if isDiff then @_emitChange @value, @previous

					paths: 
						Dirty:
							transitions: [
								{destination: 'Unloaded/Loaded', action: 'commit'}
								{destination: 'Unloaded/Loaded', action: 'rollback'}
							]
							methods:
								commit: -> Stateful.Success
								rollback: -> 
									@value = @previous
									@_emitChange @value


# ---------------------------------------------------------------------------------------

	@define "name",       get: -> @config.name
	@define "owner",      get: -> @config.owner
	@define "readonly",   get: -> if @config.readonly? then @config.readonly else false
	@define "required",   get: -> if @config.isRequired? then @config.isRequired else false
	@define "transient",  get: -> if @config.isTransient? then @config.isTransient else false

	@define 'typeString', get: -> @config.type
	@define 'type',
		get: -> 
			if TypeRegister.isModel(@config.type) then TypeRegister.getModel @config.type 
			else TypeRegister.resolve @config.type

	@registerAttribute: (name) -> TypeRegister.addAttribute name, @

# ---------------------------------------------------------------------------------------

	constructor: (config) ->
		super(config)
		
		@state = 'Unloaded'

		@value    = undefined
		@previous = undefined

		# TODO add support for validation

	get: -> @value
	raw: -> @value
					
	_applyValue: (value) -> throw new Error "Override _applyValue on #{@}"	
	_emitChange: (newValue, oldValue, metadata) -> @emit "change", @, newValue, oldValue, metadata

module.exports = Attribute
