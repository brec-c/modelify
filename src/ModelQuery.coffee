Collection = require './Collection'

class ModelQuery extends Collection
	
	constructor: (config) ->
		super(config)
		
		@store = @config.store

		if @config.where then @where @config.where 
		else
			@filter = (model) -> return true

		@run() if @config.runNow
			
	dispose: ->
		@removeAll()
		
		@store.removeListener 'add',    => @onModelAddedToStore
		@store.removeListener 'remove', => @onModelRemovedFromStore
		
		super()

	where: (filterObj) ->
		@filter = (model) ->
			for key, value of @config.where
				# TODO add support for detecting a model being referenced by ID too
				if model[key] isnt value then return false
			return true

		if @length > 0 then @run()	
						
		return @
			
	run: ->
		@removeAll()
		
		@store.on 'add',    => @onModelAddedToStore
		@store.on 'remove', => @onModelRemovedFromStore

		@onModelAddedToStore @store, model for model in @store.getAll()
			
		return @

	onModelAddedToStore: (store, model) ->
		#
		# always do this so we can monitor changes on the 
		# model to see if it should be added or removed from query
		#
		model.on 'change', => @onModelChange
		
		return unless model.is "ready"
		
		@add model if @filter model
	
	onModelRemovedFromStore: (store, model) ->
		model.removeListener 'change', => @onModelChange
		
		@remove model
				
	onModelChange: (model, change) ->
		unless @_doesQueryCareAboutState model then return
		unless @_doesQueryCareAboutChange change.property then return
		
		if @filter model
			@add model
			@sort @sortByFunc
		else 
			@remove model


	_doesQueryCareAboutState: (model) -> return not model.isIn "empty,loading".split(',')
	_doesQueryCareAboutChange: (attrName) ->
		return true unless @config.where or @config.sort?.by
		
		for key of @config.where
			if key is attrName then return true
		
		if @config.sort.by is attrName then return true

		return false

	add: (model) ->
		return if @contains model
		
		# XXX REMOVE SORTING
		
		idx = null #@findSortedIndex model
		
		super model, idx
				
	remove: (model) ->
		return unless @contains model
		
		super model
		
module.exports = ModelQuery
