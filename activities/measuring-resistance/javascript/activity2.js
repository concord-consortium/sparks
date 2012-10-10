//= require "setup-common"
//= require <jquery/jquery-1.4.2.min>
//= require <jquery/jquery-ui-1.8.custom.min>
//= require <jquery/plugins/jquery.url.packed>
//= require <jquery/plugins/jquery.cookie>
//= require <jquery/plugins/jquery.bgiframe.min>
//= require <jquery/plugins/jquery.flash>
//= require <helpers/flash_version_detection>
//= require <helpers/flash_version_detection>
//= require <helpers/flash_comm>
//= require <helpers/util>

/* FILE activity.js */

// Note: This is only used for Module 1, measuring-resistance. This class is not
// used for the breadboard activities

(function () {

    sparks.config.root_dir = '../..';

    $(document).ready(function () {
        init();
    });

    this.init = function () {
      console.log('ENTER init');
      try {
          var activity = new sparks.config.Activity();
          activity.onDocumentReady();
          activity.onFlashReady();
          sparks.activity = activity;
      }
      catch (e) {
          console.log('ERROR: init: ' + e);
      }
    };

    /*
     * This function gets called from Flash after Flash has set up the external
     * interface. Therefore all code that sends messages to Flash should be
     * initiated from this function.
     */
    this.initActivity = function () {
        console.log("flash loaded");
        sparks.activity.onActivityReady();
    };

    sparks.Activity = function () {

    };

    sparks.Activity.prototype = {

        init: function () {
        },

        setDataService: function () {
        },

        buttonize: function () {
            $('button').button();
        }
    };

})();
