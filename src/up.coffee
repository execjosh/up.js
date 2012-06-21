http = require "http"
fs = require "fs"
path = require "path"
url = require "url"
util = require "util"

# Get media type based on file extension
ext2mediaType = do ->
  mediaTypeMap =
    ".coffee": "text/coffeescript"
    ".css": "text/css"
    ".html": "text/html"
    ".js": "application/javascript"
    ".json": "application/json"
    ".txt": "text/plain"
  (ext) -> mediaTypeMap[ext] ? "application/octect-stream"

# Sandbox the pathname to rootPath
sandboxPath = (rootPath, pathname) ->
  path
    .relative(rootPath, path.join rootPath, pathname)
    .replace(/(\.\.\/?)*/, "#{rootPath}/")

# Route the request
route = (req, res, opts, cb) ->
  parsedUrl = url.parse req.url
  pathname = parsedUrl.pathname

  util.debug "Pathname: #{pathname}"

  # Map "/" to "/index.html"
  if /\/$/.test pathname
    pathname += "index.html"

  # Sandbox the path
  localPath = sandboxPath opts.rootPath, pathname

  util.debug "  Local path: #{localPath}"

  fs.stat localPath, (err, stats) ->
    if err?
      switch err.code
        when "ENOENT"
          status = 404
          util.debug "!!! Cannot find: #{localPath}"
        else
          status = 500
          body = "#{err.code}\n"
      return cb status, "text/plain", body
    else if stats.isFile()
      status = 200
      contentType = ext2mediaType path.extname localPath
      if req.method is "HEAD"
        return cb status, contentType
      stream = fs.createReadStream localPath
      stream.on "error", (err) ->
        status = 500
        contentType = "text/plain"
        data = "Internal Server Error\n"
        return cb status, contentType, data
      res.statusCode = status
      res.setHeader "Content-Type", contentType
      stream.pipe res
    else
      util.debug "!!! Does not exist: #{localPath}"
      return cb 404, "text/plain"
    return
  return

# Build a function for use with the http module
up = (opts = {}) ->
  opts.rootPath ?= process.cwd()
  opts.rootPath = path.resolve opts.rootPath
  (req, res) ->
    # Only accept GET and HEAD requests
    unless req.method in ["GET", "HEAD"]
      res.writeHead 400
      res.end()
      return
    route req, res, opts, (status, contentType, body) ->
      headers = {}
      if contentType?
        headers["Content-Type"] = contentType
      res.writeHead status, headers

      if body?
        res.end body
      else
        res.end()
      return
    return

up.VERSION = "0.1.0"

# Exports
module.exports = up
