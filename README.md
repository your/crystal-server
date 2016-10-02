# crystal-server

Simple example of HTTP server made using Crystal.

## How it works

This server allows GET requests in the following format only:

```
  GET /raw/html/filename-without-extension
  GET /raw/js/filename-without-extension
  GET /raw/css/filename-without-extension
```

Files have to be stored under the `store/raw` subfolders `(html|js|css)` with their own extension, but they must be requested without expliciting it.

Every request is cached permanently in memory, that means each file content will reside in memory as long as the process is running.

Yes, it can handle concurrent requests.

## Test

Run `crystal server.cr` and go to [http://localhost:8081/raw/html/test](http://localhost:8081/raw/html/test)

## TODO

Better caching and much more.

## Licence: MIT
