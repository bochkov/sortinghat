import os
import osproc
import strutils

proc move(hash: string, dir: string, name: string) =
  echo "hash=$1, dir=$2, name=$3" % [hash, dir, name]
  var settings: string
  settings = readFile("$1/settings.ini" % getAppDir())
  var row: seq[string]
  var changed: bool = false
  for i in settings.split("\n"):
    if i != "" and not i.startsWith("#"):
      row = i.split("=")
      if name.startsWith(row[0]):
        if hash != "":
          discard execCmd("transmission-remote --torrent $1 --remove" % [hash])
        echo "try to move $1/$2 to $3/$4" % [dir, name, row[1], name]
        discard execCmd("mv $1/$2 $3/$4" % [dir, name, row[1], name])
        echo "moved $1/$2 to $3/$4" % [dir, name, row[1], name]
        changed = true
        break
  if not changed:
    echo "torrent=$1 ignored" % [name]

if isMainModule:
  var hash, dir, name: string
  dir = os.getEnv("TR_TORRENT_DIR")
  name = os.getEnv("TR_TORRENT_NAME")
  hash = os.getEnv("TR_TORRENT_HASH")
  if name == "" and hash == "" and paramCount() == 0:
    echo "Usage: sortinghat <name>"
  else:
    var file : string = paramStr(1)
    dir = file.splitFile().dir
    name = file.extractFilename()
    move(hash, dir, name)
    