#!/usr/bin/env /usr/local/bin/coffee

{Model} = require '../src'
util    = require 'util'

# ---------------------------------------------------------------------------------------

class User extends Model

	@property 'name',  'String'
	@property 'test',  'Number'
	
	@reference 'fav', 'Beer'
	
	@registerModel 'User'

# ---------------------------------------------------------------------------------------

class Beer extends Model

	@property 'kind',  'String'
	@property 'obj',   'Object'

	@registerModel 'Beer'

# ---------------------------------------------------------------------------------------

me = User.resolve
	name: 'brec'
	test: '123'
	fav: 1

beer = Beer.create
	id: 1
	kind: 'wit'
	obj:  text: 'hello'

console.log "me is in #{me.stateName}"
console.log "beer is in #{beer.stateName}"

console.log "me.toJSON: #{util.inspect me.toJSON()}"
console.log "beer.toJSON is #{util.inspect beer.toJSON()}"
