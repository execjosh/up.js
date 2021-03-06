// Generated by CoffeeScript 1.3.3
(function() {
  var ext2mediaType, fs, http, path, route, sandboxPath, up, url, util;

  http = require("http");

  fs = require("fs");

  path = require("path");

  url = require("url");

  util = require("util");

  ext2mediaType = (function() {
    var mediaTypeMap;
    mediaTypeMap = {
      ".coffee": "text/coffeescript",
      ".css": "text/css",
      ".html": "text/html",
      ".js": "application/javascript",
      ".json": "application/json",
      ".txt": "text/plain"
    };
    return function(ext) {
      var _ref;
      return (_ref = mediaTypeMap[ext]) != null ? _ref : "application/octect-stream";
    };
  })();

  sandboxPath = function(rootPath, pathname) {
    return path.relative(rootPath, path.join(rootPath, pathname)).replace(/(\.\.\/?)*/, "" + rootPath + "/");
  };

  route = function(req, res, opts, cb) {
    var localPath, parsedUrl, pathname;
    parsedUrl = url.parse(req.url);
    pathname = parsedUrl.pathname;
    util.debug("Pathname: " + pathname);
    if (/\/$/.test(pathname)) {
      pathname += "index.html";
    }
    localPath = sandboxPath(opts.rootPath, pathname);
    util.debug("  Local path: " + localPath);
    fs.stat(localPath, function(err, stats) {
      var body, contentType, status, stream;
      if (err != null) {
        switch (err.code) {
          case "ENOENT":
            status = 404;
            util.debug("!!! Cannot find: " + localPath);
            break;
          default:
            status = 500;
            body = "" + err.code + "\n";
        }
        return cb(status, "text/plain", body);
      } else if (stats.isFile()) {
        status = 200;
        contentType = ext2mediaType(path.extname(localPath));
        if (req.method === "HEAD") {
          return cb(status, contentType);
        }
        stream = fs.createReadStream(localPath);
        stream.on("error", function(err) {
          var data;
          status = 500;
          contentType = "text/plain";
          data = "Internal Server Error\n";
          return cb(status, contentType, data);
        });
        res.statusCode = status;
        res.setHeader("Content-Type", contentType);
        stream.pipe(res);
      } else {
        util.debug("!!! Does not exist: " + localPath);
        return cb(404, "text/plain");
      }
    });
  };

  up = function(opts) {
    var _ref;
    if (opts == null) {
      opts = {};
    }
    if ((_ref = opts.rootPath) == null) {
      opts.rootPath = process.cwd();
    }
    opts.rootPath = path.resolve(opts.rootPath);
    return function(req, res) {
      var _ref1;
      if ((_ref1 = req.method) !== "GET" && _ref1 !== "HEAD") {
        res.writeHead(400);
        res.end();
        return;
      }
      route(req, res, opts, function(status, contentType, body) {
        var headers;
        headers = {};
        if (contentType != null) {
          headers["Content-Type"] = contentType;
        }
        res.writeHead(status, headers);
        if (body != null) {
          res.end(body);
        } else {
          res.end();
        }
      });
    };
  };

  up.VERSION = "0.1.0";

  module.exports = up;

}).call(this);
