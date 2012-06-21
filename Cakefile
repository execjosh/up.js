{spawn, exec} = require "child_process"
fs = require "fs"
path = require "path"

################################################################################
#
# From coffee-script project's Cakefile
enableColors = no
unless process.platform is 'win32'
  enableColors = not process.env.NODE_DISABLE_COLORS
bold = red = green = reset = ''
if enableColors
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'
log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')
#
################################################################################

task "build:lib", "build `up` library", (opts = {}) ->
  log "Building lib...", green
  coffee = spawn "coffee", ["-c", "-o", "lib", "src/up.coffee"]
  coffee.stdout.on "data", (chunk) ->
    log "CoffeeScript: ", red, chunk.toString().trim()
    return
  return

task "build:bin", "build `up` binary", (opts = {}) ->
  log "Building bin/up...", green
  fs.mkdir "bin", (err) ->
    if err?
      unless err.code is "EEXIST"
        console.log err
        return
    stream = fs.createWriteStream "bin/up"
    stream.on "open", (fd) ->
      stream.write "#!/usr/bin/env node\n\n"
      coffee = spawn "coffee", ["-c", "-p", "src/cli.coffee"]
      coffee.stdout.pipe stream
      return
    stream.on "close", ->
      fs.chmod "bin/up", 0o0755
      return
    return
  return

task "build:doc", "build `up` docs", (opts = {}) ->
  log "Building docs...", green
  invoke "dir:man"
  fs.readFile "doc/up.1.ronn", (err, data) ->
    if err?
      log err, red
      process.exit 1
      return
    up = require "./src/up"
    Ronn = require("ronn").Ronn
    version = "UP #{up.VERSION}"
    manual = "UP MANUAL"
    date = new Date
    roff = do ->
      ronn = new Ronn data, version, manual, date
      ronn.roff()
    file = "man/man1/up.1"
    name = path.basename(file).replace /\.(\d+)$/, "($1)"
    fs.writeFile file, roff, (err) ->
      if err?
        log err, red
        process.exit 1
      return
    html = do ->
      ronn = new Ronn data, version, manual, date
      ronn.fragment()
        # Fixup header
        .replace(/\<h1\>((.*?) -- (.*?))\<\/h1\>/,
          (str, p1, p2, p3, p4, s) ->
            """
            <h2 id="NAME">NAME</h2>

            <p>#{p1.replace /(.*?)\(\d+\)( --)/, "<strong>$1</strong>$2"}</p>
            """
        )
        .replace(/:\n+(.*?)<\/p>/g, "</p><dd>$1</dd>")
    htmlFile = path.join("html", "#{path.basename file}.html")
    fs.readFile "html/_man-template.html", (err, data) ->
      content = data.toString("utf-8")
        .replace(/{{\s*?BODY\s*?}}/g, html)
        .replace(/{{\s*?NAME\s*?}}/g, name)
        .replace(/{{\s*?DATE\s*?}}/g, "&nbsp;")
        .replace(/{{\s*?VERSION\s*?}}/g, version)
        .replace(/{{\s*?MANUAL\s*?}}/g, manual)
      fs.writeFile htmlFile, content, (err) ->
        if err?
          log err, red
          process.exit 1
        return
      return
    return
  return

task "build:all", "build all", ->
  invoke "build:lib"
  invoke "build:bin"
  invoke "build:doc"
  return

task "dir:man", "dir:man", do ->
  alreadyRan = false
  mkdirs = (dirs...) ->
    for dir in dirs
      try
        fs.mkdirSync dir
      catch err
        unless err.code is "EEXIST"
          log err, red
          process.exit 1
    return
  ->
    return if alreadyRan
    mkdirs "man", "man/man1"
    mkdirs "html"
    alreadyRan = yes
    return
