up.js
=====

A simple static file HTTP server for node.js useful for quickly serving files.

Installation
============

```bash
$ git clone git://github.com/execjosh/up.js.git
$ cd up.js
$ sudo npm link
```

Usage
=====

    up [OPTIONS]

`OPTIONS`
---------

    --addr=[HOST][:PORT]    The host and/or port on which to listen (default: 0.0.0.0:1337)
    --root=PATH             The directory from which to serve files (default: current working directory)
    --version               Display the version and exit

Supported Media Types
=====================

```json
{
  ".css": "text/css"
, ".html": "text/html"
, ".js": "application/javascript"
, ".json": "application/json"
, ".txt": "text/plain"
}
```
