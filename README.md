# crystal-server

Simple example of HTTP server made using Crystal.

## How it works

This server allows GET requests in the following format:

```
  GET /raw/html/filename-without-extension
  GET /raw/js/filename-without-extension
  GET /raw/css/filename-without-extension
```

Files have to be stored under the `store/raw` subfolders `(html|js|css)` with their own extension, but they must be requested without expliciting it.

Yes, it can handle concurrent requests.

## URL shortcuts

The following conversion matrix is now available to access resources using a shorter URL:

```
  GET /html-filename-without-extension -> /raw/html/html-filename-without-extension
  GET /filename.js -> /raw/js/filename-without-extension
  GET /filename.css -> /raw/css/filename-without-extension
```

## Cache

Every request is cached permanently in memory, that means each file content will reside in memory as long as the process is running.

To force a cache cleanup without killing the process send a `kill -SIGHUP pid`.

## Test

Run `crystal-server` and go to [http://localhost:8081/raw/html/test](http://localhost:8081/raw/html/test) (or [http://localhost:8081/test](http://localhost:8081/test))

## TODO

Better caching and much more.

## Licence: MIT
