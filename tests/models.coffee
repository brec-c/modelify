{Model} = require '../src'

class User extends Model

	@property 'name',     'String'

	@registerModelType()


class Beer extends Model

	@property 'kind',     'String'

	@registerModelType()

me = new User name: 'brec'
beer = new Beer kind: 'wit'

console.log "me is in #{me.state}, me store is #{me.store.type.name}"
console.log "beer is in #{beer.state}, beer store is #{beer.store.type.name}"

console.log "me.name is #{me.name}"
console.log "beer.kind is #{beer.kind}"

# q = User.find()

# console.log "num users is #{q.length}"
