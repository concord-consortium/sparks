/*globals console sparks $ breadModel getBreadBoard window alert*/

(function() {

  /*
   * Sparks Class Report Controller can be accessed by the
   * singleton variable sparks.classReportController
   *
   * There is only one singlton sparks.classReport object. This
   * controller creates it when the controller is created.
   */
  sparks.ClassReportController = function(){
    // sparks.classReport = new sparks.ClassReport();
    this.reports = [];

    this.className = "";
    this.teacherName = "";
    // this.view = new sparks.ClassReportView();
  };

  sparks.ClassReportController.prototype = {

    getClassData: function(activityId, learnerIds, classId, callback) {

    },

    getLevels: function() {
      if (this.reports.length > 0){
        var reportWithMostSections = 0,
            mostSections = 0;
        for (var i = 0, ii = this.reports.length; i < ii; i++){
          var numSections = this.reports[i].sectionReports.length;
          if (numSections > mostSections){
            mostSections = numSections;
            reportWithMostSections = i;
          }
        }
        var sectionReports = this.reports[reportWithMostSections].sectionReports;
        return $.map(sectionReports, function(report, i) {
          return (report.sectionTitle);
        });
      }
      return [];
    }

  };

  sparks.classReportController = new sparks.ClassReportController();
})();