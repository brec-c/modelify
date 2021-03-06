// Generated by CoffeeScript 1.3.3
(function() {
  var Base, Stateful,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Stateful = require('stateful');

  Base = (function(_super) {

    __extends(Base, _super);

    Base.mixin = function(type) {
      var method, name, _results;
      _results = [];
      for (name in type) {
        method = type[name];
        _results.push(this.prototype[name] = method);
      }
      return _results;
    };

    function Base(config) {
      this.config = config != null ? config : {};
      Base.__super__.constructor.call(this, this.config);
    }

    return Base;

  })(Stateful);

  module.exports = Base;

}).call(this);
