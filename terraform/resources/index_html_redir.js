function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Check if the URI ends with a directory, add index.html to the URI
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
