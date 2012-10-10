/*globals console sparks $ breadModel getBreadBoard */

(function() {
  sparks.ActivityConstructor = function(jsonActivity){
    // sparks.sectionController.reset();
    // this.section = sparks.sectionController.createSection(jsonSection);

    sparks.activity.view = new sparks.ActivityView();

    if (!jsonActivity.type || jsonActivity.type !== "activity"){
      var jsonSection = jsonActivity;
      var section = sparks.activityController.addSection(jsonSection);
      this.loadFirstSection();
    } else {
      sparks.activityController.createActivity(jsonActivity, this.loadFirstSection);
    }

    sparks.activityConstructor = this;

  };

  sparks.ActivityConstructor.prototype = {
    loadFirstSection: function() {
      sparks.activityController.setCurrentSection(0);
      sparks.sectionController.loadCurrentSection();
      sparks.activity.view.layoutCurrentSection();
    }

  };
})();