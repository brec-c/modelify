{Model} = require '../src'
util    = require 'util'

class User extends Model

	@property 'name',  'String'
	@property 'test',  'Number'
	
	@reference 'fav', 'Beer'
	
	# @collection 'beers', 'Beer'

	@registerModel 'User'


class Beer extends Model

	@property 'kind',  'String'
	@property 'obj',   'Object'

	@registerModel 'Beer'

me = new User 
	name: 'brec'
	test: 123
	
beer = new Beer 
	kind: 'wit'
	obj:  text: 'hello'

console.log "me is in #{me.state}"
console.log "beer is in #{beer.state}"

console.log "me.toJSON: #{util.inspect me.toJSON()}, me.attributes: #{util.inspect me.attributes}"
console.log "beer.toJSON is #{util.inspect beer.toJSON()}"

# q = User.find()

# console.log "num users is #{q.length}"
