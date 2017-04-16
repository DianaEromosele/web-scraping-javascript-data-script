The easy way is to just add the extension in google chrome to allow access using CORS.

https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi?hl=en-US

Just enable this extension whenever you want allow access to no 'access-control-allow-origin' header request.


If I understood it right you are doing an XMLHttpRequest to a different domain than your page is on. So the browser is blocking it as it usually allows a request in the same origin for security reasons. You need to do something different when you want to do a cross-domain request. A tutorial about how to achieve that is Using CORS.

Regular web pages can use the XMLHttpRequest object to send and receive data from remote servers, but they're limited by the same origin policy. Extensions aren't so limited. An extension can talk to remote servers outside of its origin, as long as it first requests cross-origin permissions.