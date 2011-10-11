/* FILE capacitor.js */
//= require "component"
/*globals console sparks */

(function () {

  sparks.circuit.Capacitor = function (props, breadBoard) {
    sparks.circuit.Capacitor.parentConstructor.call(this, props, breadBoard);
  };

  sparks.extend(sparks.circuit.Capacitor, sparks.circuit.Component, {
    init: function (id) {
      this.id = id;
    },
    
    getCapacitance: function () {
      return this.capacitance;
    }
  });

})();