/*global $ sparks*/

(function() {

	sparks.IntelData = {};

	var postDataURL = "/postData",

			appId = {
				id:      "org.concord.sparks",
				name:    "SPARKS",
				version: 0.1
			},

			actions = {
				enterQuestion:      "enter question",
				submitAnswer:       "submit",
				enterPageReport:    "enter page report",
				enterSectionReport: "enter section report"
			},

			sendMessage = function (action, location, data) {
				var postData = {
					appId:    appId,
					action:   action,
					location: location
				};

				if (data) {
					postData.data = data;
				}

				$.post(postDataURL, JSON.stringify(postData));
			},

			// optional 'page' as section.currentPage is not set until after first
			// question is entered
			getCurrentLocation = function (page) {
				var location = [],
						section, page;

				if (sparks.activity) {
					location.push({type: "Activity", id: sparks.activity.id});

					section = sparks.activityController.currentSection;
					location.push({type: "Section", id: section.id, title: section.title});

					if (typeof page == "boolean" && !page) {
						return location;
					}

					page = page || sparks.sectionController.currentPage;
					location.push({type: "Page", id: page.id});

					location.push({type: "Question", id: page.currentQuestion.id});
				}

				return location;
			};

	sparks.IntelData.enterQuestion = function (page) {
		sendMessage(actions.enterQuestion, getCurrentLocation(page));
	};

	sparks.IntelData.enterPageReport = function (page) {
		sendMessage(actions.enterPageReport, getCurrentLocation(page));
	};

	sparks.IntelData.enterSectionReport = function () {
		sendMessage(actions.enterSectionReport, getCurrentLocation(false));
	};

	sparks.IntelData.submitAnswer = function (question) {
		sparks.questionController.gradeQuestion(question);
		var data = {
			response: question.answer,
			solution: question.correct_answer,
			feedback: question.feedback,
			maxScore: question.points,
			score:    question.points_earned
		};
		sendMessage(actions.submitAnswer, getCurrentLocation(), data);
	};
})();