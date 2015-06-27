// Listen on port 9001
var gith = require('gith').create( 9001 );
// Import execFile, to run our bash script
var execFile = require('child_process').execFile;

// Auto deploy the client
gith({
    repo: 'thebillkidy/Feedient-Client',
    branch: 'production'
}).on( 'all', function( payload ) {
    // Exec a shell script
    execFile('/opt/git_hooks/deploy_client.sh', function(error, stdout, stderr) {
        // Log success in some manner
        console.log('deployed client');
    });
});