Stateful = require 'stateful'
_        = require 'underscore'

class Collection extends Stateful
	
	@define  "lastPos", get: -> Math.max @length-1, 0
	
	#
	# Initializes the {Collection}.
	#
	# @config {Array-like} items Items to add to the collection immediately after creation.
	#
	constructor: (config) ->
		super(config)
		@length = 0
		@addAll(@config.items) if @config.items?
		
		if @config.sort?.by?
			@sortByFunc = 
				if @config.sort.dir? and @config.sort.dir is 'desc'
					(a,b) => if a[@config.sort.by]>b[@config.sort.by] then -1 else 1
				else
					(a,b) => if a[@config.sort.by]<b[@config.sort.by] then -1 else 1
		else
			@sortByFunc = (a,b) => return 0

	clone: -> new Collection items: @
	
	#
	# Adds the specified item to the end of the collection.
	#
	# @param {Mixed} item The item to add.
	# @returns The collection.
	#
	add: (item, index=null) ->
		# console.error "#{@} add #{item}"
		if index is null or index is @length
			index = @length
			@[index] = item
			@length++
			@onAdd(item, index)
		else
			if typeof index isnt 'number' or index < 0
				throw new Error("Bad index #{index}")

			tail = @rest(index)
			@[index] = item
			@length++
			@_reattach(tail, index + 1)
			@onAdd(item, index)
			
		#hackety hack for reverse sort	
		if @config.sort?.dir is 'desc'
			@sort()
			@onAdd(item, @indexOf(item))
			@emit 'change', @
			
			
		return this
	
	#
	# Adds all of the items in the specified array-like object to the collection.
	#
	# @param {Array-like} item An array-like object containing items to add.
	# @returns The collection.
	#
	addAll: (collection) ->
		@add(item) for item in collection
		return this

	#
	# Compares two Collections to see if their contents are the same.
	#
	# @param {Array-like} An array-like object containing items to be compared to this
	# collection's contents.  Content value and position are considered.
	# @returns boolean
	#	
	isEqual: (collection) ->
		unless collection then return false
		if @length isnt collection.length then return false
		
		for item,index in collection
			if item isnt @[index] then return false

		return true

	#
	# Returns a value indicating whether or not the collection is empty.
	#
	# @returns True if the collection is empty, otherwise false.
	#
	isEmpty: ->	@length is 0
	
	#
	# Returns a value indicating whether or not the collection contains the same items (in the same order)
	# as the specified array-like object.
	#
	# @param {Array-like} other The array-like object of items to compare.
	# @returns True if the collection contains the same items, otherwise false.
	#
	equals: (other) -> _.isEqual(this, other)
	
	#
	# Inserts an item into the collection at the specified index, moving the remainder of the items down one index.
	#
	# alias for add
	#
	# @param {Mixed}  item  The item to add.
	# @param {Number} index The index at which to insert the item.
	# @returns The collection.
	#
	insert: (item, index) -> @add item, index
	
	#
	# Removes the specified item from the collection.
	#
	# @param {Mixed} item The item to remove.
	# @returns The item that was removed, or undefined if the item wasn't found in the collection.
	#
	remove: (item) ->
		index = @indexOf(item)
		if index is -1
			undefined
		else
			@removeAt(index)
	
	#
	# Removes the item at the specified index from the collection.
	#
	# @param {Number} index The index of the item to remove.
	# @returns The item that was removed, or undefined if the item wasn't found in the collection.
	#
	removeAt: (index) ->
		if index < 0 or index > @length - 1
			return undefined
		
		item = @[index]
		delete @[index]
		
		tail = @rest(index + 1)
		@_reattach(tail, index)
		
		delete @[@length]
		@length--
		
		@onRemove(item, index)
		return item
	
	#
	# Removes all items from the collection.
	#
	removeAll: ->
		@removeAt(index) for index in [@length-1..0]
		return this
	
	#
	# Moves an item from one index to another.
	#
	# @param {Number} oldIndex The index to move the item from.
	# @param {Number} newIndex The index to move the item to.
	# @returns The item that was moved.
	#
	move: (oldIndex, newIndex) ->
		if oldIndex is newIndex then return @[oldIndex]
		
		if oldIndex >= @length
			throw new Error "Can't move item from out-of-bounds index #{oldIndex} (Collection contains #{@length} items.)"
		if newIndex >= @length
			throw new Error "Can't move item to out-of-bounds index #{newIndex} (Collection contains #{@length} items.)"
			
		item = @removeAt(oldIndex)
		@insert item, newIndex
		return item
	
	#
	# Alias for add().
	#
	push: (item) -> @add(item)

	#
	# Removes an item from the end of the collection.
	# @returns The item that was removed, or undefined if the collection was empty.
	#
	pop: -> if @length is 0 then undefined else @removeAt(@length - 1)

	#
	# Removes an item from the beginning of the collection.
	# @returns The item that was removed, or undefined if the collection was empty.
	#
	shift: -> if @length is 0 then undefined else @removeAt(0)

	#
	# Adds an item to the beginning of the collection.
	#
	# @param {Mixed} item The item to add.
	# @returns The collection.
	#
	unshift: (item) -> @insert(item, 0)

	#
	# Converts the collection to an actual JavaScript array object.
	#
	toArray: -> @values()

	#
	# Returns a string representation of the collection, joined by the specified separator.
	#
	# @param {String} separator The separator to use.
	#
	join: (separator = ', ') -> @toArray().join(separator)
	
	#
	# Called when an item is added to the collection.
	#
	# @param {Mixed}  item  The item to add.
	# @param {Number} index The index at which to insert the item.
	#
	onAdd: (item, index) ->
		@emit('add', item, index)
		@emit 'change'

	#
	# Called when an item is removed from the collection.
	#
	# @param {Mixed}  item  The item to add.
	# @param {Number} index The index at which to remove the item.
	#
	onRemove: (item, index) ->
		@emit('remove', item, index)
		@emit 'change'

	#
	# Re-attaches a list of items to the end of the collection.
	# @private
	#
	_reattach: (tail, index) -> @[index++] = obj for obj in tail
	
	#
	# The following methods are dynamically mixed into the prototype of {Collection}.
	# The implementation of each just proxies to underscore.js.
	#
	
	sort: ->
		if @config.sort?.by?
			# console.error "#{@} sort #{JSON.stringify @config.sort}"
			values = @toArray()
			
			values.sort @sortByFunc

			changed = false
			for i,v of values
				if @[i] isnt v
					@[i] = v
					changed = true
			
			@emit 'change', @ if changed
			
		return @
	
	@underscoreProxyMethods: [
		'all'
		'any'
		'compact'
		'contains'
		'detect'
		'difference'
		'each'
		'every'
		'filter'
		'find'
		'first'
		'flatten'
		'forEach'
		'groupBy'
		'include'
		'indexOf'
		'intersection'
		'invoke'
		#'isEqual' # FFS this causes an infinite loop in underscore's impl.
		'last'
		'lastIndexOf'
		'map'
		'max'
		'min'
		'pluck'
		'range'
		'reduce'
		'reduceRight'
		'reject'
		'rest'
		'select'
		'size'
		'some'
		# 'sortBy'
		# 'sortedIndex'
		'union'
		'uniq'
		'without'
		'values'
		'zip'
	]

	for method in @underscoreProxyMethods
		do (method) =>
			@::[method] = (args...) -> _[method].apply(_, [this].concat(args))

module.exports = Collection
