Model = require '../src/Model'
Util = require '../src/Util'

class User extends Model

	@property 'id', 'String'
	@property 'name', 'String'
	@property 'username', 'String'


module.exports = Util.registerPlugin 'model', 'user', User