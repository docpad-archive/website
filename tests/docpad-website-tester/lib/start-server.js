var path = require('path');
var childProcess = require('child_process');

function start(opts, callback) {

	var port = opts.port || '9778';
	var ip = opts.ip || '127.0.0.1';
	var useDocPad = opts.useDocPad || true;

	var APP_PATH = process.cwd();
	var MODULES_PATH = path.join(APP_PATH, "node_modules");
	var DOCPAD = path.join(MODULES_PATH, "docpad/bin/docpad");
	var OUT_PATH = path.join(APP_PATH, "out");


	var child = childProcess.spawn('node', [DOCPAD, 'server'], {
		output: true,
		cwd: APP_PATH
	});

	child.stdout.on('data', function (chunk) {
		var str = chunk.toString().trim();
		console.log(str);
		if (str.indexOf("The action completed successfully") > -1) {
			console.log("DocPad is ready...");
			if (useDocPad) {
				callback(child);
			} else {
				child.kill();
			}
		}
	});

	if (!useDocPad) {
		child.on('close', function (code) {
			console.log("DocPad closed..." + code);

			var server = httpServer.createServer({
				root: OUT_PATH
			});
			server.listen('9778', '127.0.0.1');
			callback(server);
		});
	}

}


module.exports.start = start;