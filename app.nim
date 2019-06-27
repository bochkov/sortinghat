import os
import osproc
import strutils
import system

const SETTINGS_FILE : string = "settings.ini"

proc getTarget(source: string) : string =
  var settings : string = readFile("$1/$2" % [getAppDir(), SETTINGS_FILE])
  for line in settings.split("\n"):
    var elems: seq[string] = line.split("=")
    if line.startsWith(source):
      return elems[1]
    else:
      return ""

proc stopTransmission(hash: string) =
  if hash != "":
    discard execCmd("transmission-remote --torrent $1 --remove" % hash)

proc mv(source, target: string) =
  echo "try to move $1 to $2" % [source, target]
  discard execCmd("mv $1 $2" % [source, target])
  echo "moved $1 to $2" % [source, target]

if isMainModule:
  var hash, name, dir : string = ""
  if paramCount() == 0:
    hash = getEnv("TR_TORRENT_HASH")
    name = getEnv("TR_TORRENT_NAME")
    dir  = getEnv("TR_TORRENT_DIR")
  else:
    name = paramStr(1).extractFilename()
    dir = paramStr(1).splitFile().dir
    if dir == "" or dir == ".":
      dir = getAppDir()

  if hash == "" and name == "":
    echo "Usage: sortinghat <name>"
    quit(1)
    
  var target: string = getTarget(name)
  if target != "":
    stopTransmission(hash)
    var source: string = "$1/$2" % [dir, name]
    source.mv(target)
