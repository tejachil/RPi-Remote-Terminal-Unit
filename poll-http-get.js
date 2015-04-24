var request = require('request');

// Set the headers
var headers = {
    'User-Agent':       'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36',
    'Content-Type':     'text/plain'
}

// Configure the request
var options = {
    url: 'http://localhost:8080',
    method: 'GET',
    headers: headers
}

var interval = setInterval( function() {
    request(options, function (error, response, body) {
    if (!error && response.statusCode == 200) {
        // Print out the response body
        console.log(body.trim())
    }
    if(error)
        console.log("error");
    })
    //console.log(counter);
}, 0.5);
// Start the request
