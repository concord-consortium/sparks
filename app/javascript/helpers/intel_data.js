/*global $ sparks*/

(function() {

	sparks.IntelData = {};

	var postDataURL = "http://localhost:49377",

			appId = {
				app_id:      "org.concord.sparks",
				app_name:    "SPARKS",
				app_version: "1.0"
			},

			actions = {
				enterQuestion:      "enter question",
				submitAnswer:       "submit",
				enterPageReport:    "enter page report",
				enterSectionReport: "enter section report",
				studentError:       "student error"
			},

			sendMessage = function (action, location, data) {
				var postData = {
					app_id:    	 	appId.app_id,
					app_name:    	appId.app_name,
					app_version: 	appId.app_version,
					action:   		action,
					location: 		location
				};

				if (data) {
					for (var key in data) {
						if (!data.hasOwnProperty(key)) continue;
						postData["item_"+key] = data[key];
					}
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
			question: question.shortPrompt,
			response: question.answer,
			solution: question.correct_answer,
			feedback: question.feedback,
			maxScore: question.points,
			score:    question.points_earned
		};
		sendMessage(actions.submitAnswer, getCurrentLocation(), data);
	};

	sparks.IntelData.studentError = function (message) {
		sendMessage(actions.studentError, getCurrentLocation(), {message: message});
	}
})();