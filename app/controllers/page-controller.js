/*global sparks */

(function() {

  /*
   * Sparks Page Controller can be accessed by the
   * singleton variable sparks.pageController
   */
  sparks.PageController = function(){
  };

  sparks.PageController.prototype = {

    reset: function(){
    },

    createPage: function(id, jsonPage) {
      var page = new sparks.Page(id);

      page.questions = sparks.questionController.createQuestionsArray(jsonPage.questions);
      page.currentQuestion = page.questions[0];

      if (!!jsonPage.notes){
        var notes = sparks.mathParser.calculateMeasurement(jsonPage.notes);
        page.notes = notes;
      }

      page.time = jsonPage.time;

      page.view = new sparks.PageView(page);

      return page;
    },

    enableQuestion: function(page, question) {
      page.view.enableQuestion(question);
    },

    // enables next question if available, or shows report otherwise
    completedQuestion: function(page) {
      var nextQuestion;
      for (var i = 0; i < page.questions.length-1; i++){
        if (page.questions[i] === page.currentQuestion){
          if (page.currentQuestion.isSubQuestion){
            do {
              i++;
              if (i == page.questions.length){
                this.showReport(page);
                return;
              }
            } while (i < page.questions.length && page.questions[i].subquestionId == page.currentQuestion.subquestionId);
            nextQuestion = page.questions[i];
          } else {
            nextQuestion = page.questions[i+1];
          }
        }
      }

      if (!!nextQuestion){
        page.currentQuestion = nextQuestion;
        this.enableQuestion(page, page.currentQuestion);
      } else {
        this.showReport(page);
      }
    },

    showReport: function(page){
      sparks.logController.endSession();
      var sessionReport = sparks.reportController.addNewSessionReport(page);
      sparks.reportController.saveData();
      var $report = sparks.report.view.getSessionReportView(sessionReport);
      page.view.showReport($report);
    },

    getSisterSubquestionsOf: function(page, question){
      var subquestionId = question.subquestionId,
          questions = [];

      for (var i = 0; i < page.questions.length; i++){
        if (page.questions[i].subquestionId === subquestionId) {
          questions.push(page.questions[i]);
        }
      }
      return questions;
    }

  };

  sparks.pageController = new sparks.PageController();
})();