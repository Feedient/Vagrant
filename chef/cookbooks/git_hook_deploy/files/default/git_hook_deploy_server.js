// Listen on port 9002
var gith = require('gith').create( 9002 );
// Import execFile, to run our bash script
var execFile = require('child_process').execFile;

// Auto deploy the server
gith({
    repo: 'thebillkidy/Feedient-Server',
    branch: 'production'
}).on( 'all', function( payload ) {
    // Exec a shell script
    execFile('/opt/git_hooks/deploy_server.sh', function(error, stdout, stderr) {
        // Log success in some manner
        console.log('deployed server');
    });
});