Stateful = require 'stateful'
_        = require 'underscore'
Store    = require './Store'

class Model extends Stateful

	###
	This is really how I want to describe the states of a model.
	Need to update stateful to support this.
	
	ALL_CAPS -> these are States.  These you enter / exit
	One_cap -> these are actions.  These are available actions to perform when in the owning state.
	
	Siblings are mutually exclusive.
	
	'UNSAVED'
		'Updating'
		'Saving'
	
	
	'SAVED'
		'UNLOADED'
			'Loading'
			
		'LOADED'
			'Updating'
			'Editing'
			'DIRTY'
				'CONFLICTED'
				'Syncing'
	###

	# OLD WAY (similiar to rubicon model)
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
	
	@store: (name) -> @store = new Store type:@

	@get    : -> @store.get.apply @store, arguments
	@find   : -> @store.find.apply @store, arguments
	@create : -> @store.create.apply @store, arguments
	@delete : -> @store.delete.apply @store, arguments


	#
	# Model declarative definitions
	#
	@_attribute: (kind, name, type, config = {}) ->
		@::_schema = {} unless @::_schema?
		@::_schema[name] = _