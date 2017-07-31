import os
import osproc
import strutils

proc move(hash: string, dir: string, name: string) =
  echo "hash=$1, dir=$2, name=$3" % [hash, dir, name]
  var settings: string
  settings = readFile("$1/settings.ini" % getAppDir())
  var row: seq[string]
  for i in settings.split("\n"):
    if i != "" and not i.startsWith("#"):
      row = i.split("=")
      if name.startsWith(row[0]):
        if hash != "":
          discard 
            execProcess(
              command = "transmission-remote", 
              args = ["--torrent", hash, "--remove"]
            )
        echo "try to move $1/$2 to $3/$4" % [dir, name, row[1], name]
        moveFile(
          "$1/$2" % [dir, name], 
          "$1/$2" % [row[1], name]
        )
        echo "moved $1/$2 to $3/$4" % [dir, name, row[1], name]
        return
  echo "torrent=$1 ignored" % [name]

proc move(name : string) =
  move("", name.splitFile().dir, name.splitFile().name)

var
  hash, dir, name: string
dir = os.getEnv("TR_TORRENT_DIR")
name = os.getEnv("TR_TORRENT_NAME")
hash = os.getEnv("TR_TORRENT_HASH")

if name != "" and hash != "":
  move(hash, dir, name)
elif paramCount() > 0:
  move(paramStr(1))
else:
  echo "Usage: sortinghat <name>"
