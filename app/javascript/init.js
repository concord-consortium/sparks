//= require "setup-common"
//= require <jquery/jquery-1.8.1.min>
//= require <jquery/jquery-ui-1.8.24.custom.min>
//= require <jquery/plugins/jquery.url.packed>
//= require <jquery/plugins/jquery.cookie>
//= require <jquery/plugins/jquery.flash>
//= require <jquery/plugins/jquery.easyTooltip>
//= require <jquery/plugins/jquery.tablesorter.min>
//= require <jquery/plugins/jquery.event.drag-2.0.min>
//= require <helpers/util>
//= require <helpers/unit>
//= require <helpers/intel_data>
//= require <models/activity>
//= require <models/section>
//= require <models/page>
//= require <models/question>
//= require <models/log>
//= require <models/report>
//= require <views/activity-view>
//= require <views/section-view>
//= require <views/page-view>
//= require <views/question-view>
//= require <views/report-view>
//= require <views/oscilloscope-view>
//= require <views/function-generator-view>
//= require <views/class-report-view>
//= require <views/breadboard-svg-view>
//= require <controllers/question-controller>
//= require <controllers/page-controller>
//= require <controllers/log-controller>
//= require <controllers/section-controller>
//= require <controllers/activity-controller>
//= require <controllers/report-controller>
//= require <controllers/class-report-controller>
//= require <controllers/tutorial-controller>
//= require <activity-constructor>
//= require <helpers/math-parser>
//= require <helpers/string>
//= require <helpers/ui>
//= require <helpers/flash_comm>
//= require <helpers/complex-number>
//= require <circuit/breadboard>
//= require <circuit/multimeter2>
//= require <circuit/oscilloscope>
//= require <circuit/resistor-4band>
//= require <circuit/resistor-5band>
//= require <circuit/circuit-math>
//= require <circuit/inductor>
//= require <circuit/capacitor>
//= require <circuit/battery>
//= require <circuit/function-generator>
//= require <circuit/wire>
//= require <circuit/power-lead>
//= require <apMessageBox>
//= require <helpers/math>
//= require <helpers/ga-helper>

/* FILE init.js */

/*globals console sparks $ document window onDocumentReady unescape prompt apMessageBox*/

(function () {

  sparks.config.flash_id = 'breadboardActivity1';
  sparks.activity_base_url = "activities/bb-activities/";
  sparks.activity_images_base_url = "activities/images/";
  sparks.tutorial_base_url = "tutorials/";
  sparks.soundFiles = {click: "common/sounds/click.ogg"}

  window._gaq = window._gaq || [];      // in case this script loads before the GA queue is created

  $(document).ready(function () {
      onDocumentReady();
  });

  this.onDocumentReady = function () {
    if (window.location.pathname.indexOf("class-report") > -1){
      this.loadClassReport();
    } else {
      this.loadActivity();
    }
    this.setupQuitButton();
  };

  this.loadActivity = function () {
    var activityName = window.location.hash;
    activityName = activityName.substring(1,activityName.length);
    if (!activityName){
      activityName = "series-interpretive";
    }

    this.loadSounds();

    console.log("loading "+activityName);

    $.getJSON(sparks.activity_base_url + activityName, function(activity) {
      console.log(activity);
      var ac = new sparks.ActivityConstructor(activity);
    });
  };

  this.loadClassReport = function () {
    var classStudents,
        learnerIds = [],
        activity,
        classId;
    if (!!sparks.util.readCookie('class')){
      classId = sparks.util.readCookie('class');
      activity = unescape(sparks.util.readCookie('activity_name')).split('#')[1];
      classStudents = eval(unescape(sparks.util.readCookie('class_students')).replace(/\+/g," "));
      for (var i=0, ii=classStudents.length; i < ii; i++){
        learnerIds.push(classStudents[i].id);
      }
    } else {
      activity = prompt("Enter the activity id", "series-parallel-g1");                       // series-resistances
      classStudents = prompt("Enter a list of learner ids", "568,569");        // 212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228
      learnerIds = classStudents.split(',');
    }

    sparks.classReportController.getClassData(
      activity,
      learnerIds,
      classId,
      function(reports) {
        $('#loading').hide();
        var view = new sparks.ClassReportView(),
            $report = view.getClassReportView(reports);
        $('#report').append($report);
        $("#print-link").show();
      });
  };

  this.setupQuitButton = function () {
    $('#return_to_portal').click(function() {
      window.onbeforeunload = null;
      window.location.href = "http://sparks.portal.concord.org";
    });
  };

  this.loadSounds = function () {
    var soundName, audio;

    sparks.sound = {};

    sparks.sound.mute = false;

    sparks.sound.play = function (sound) {
      if (!!window.Audio && !sparks.sound.mute) {
        sound.play();
      }
    }

    for (soundName in sparks.soundFiles) {
      if (!!window.Audio) {
        audio = new Audio();
        audio.src = sparks.soundFiles[soundName];
        sparks.sound[soundName] = audio;
      }
    }
  };
})();
