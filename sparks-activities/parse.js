var fs = require('fs'),
    path = require('path'),
    sys = require('sys');

function woo () {

	json = JSON.parse(fs.readFileSync("all-activities.json").toString());

	for (i = 0; i < json.rows.length; i++) {
		row = json.rows[i];

		if (!row.doc) continue;

		id = row.doc._id;

		if (~id.indexOf("/")) continue;

		row.doc._id = id = id.replace(/ /g, "-");
		fs.writeFileSync(id+".json", JSON.stringify(row.doc, null, 2));
	}

}


exports.woo = woo;