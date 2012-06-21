#!/usr/bin/env coffee

fs = require "fs"
http = require "http"
path = require "path"
util = require "util"

up = require require("path").join __dirname, "../lib/up"

parseArgv = (argv, cb) ->
  opts =
    host: "0.0.0.0"
    port: 1337

  for opt in argv
    unless /^--/.test opt
      return cb new Error "Unknown Option: #{opt}"

    if /^--addr=(([^:]*)(:(\d*))?)?$/.test opt
      # Extract host
      host = RegExp.$2
      if host isnt null and 0 < host.length
        opts.host = host

      # Extract port
      port = +RegExp.$4
      if not isNaN(port) and 0 < port
        opts.port = port
    else if /^--root=(.*)$/.test opt
      rootPath = path.resolve RegExp.$1
      stats = fs.statSync rootPath
      unless stats.isDirectory()
        return cb new Error "Root must be a directory: #{rootPath}"
      opts.rootPath = rootPath
    else if opt is "--version"
      console.log "v#{up.VERSION}"
      return
    else
      return cb new Error "Invalid Option: #{opt}"
  return cb null, opts

argv = process.argv.slice 2
parseArgv argv, (err, opts) ->
  if err?
    throw err
  server = http.createServer up opts
  server.on "listening", ->
    addr = server.address()
    util.log "Serving #{opts.rootPath} at #{addr.address}:#{addr.port}"
    return
  server.listen opts.port, opts.host
  return
