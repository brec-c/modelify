{Model} = require '../src'

class User extends Model

	# @property 'id',       'String'
	# @property 'name',     'String'
	# @property 'username', 'String'


module.exports = User

me = new User

console.log "me is #{me.state}"

# q = User.find()

# console.log "num users is #{q.length}"
