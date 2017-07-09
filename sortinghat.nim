import os
import strutils
import osproc

proc move(name: string, hash: string) =
  echo "name=", name
  echo "hash=", hash
  var settings: string
  settings = readFile("settings.ini")
  var row: seq[string]
  for i in settings.split("\n"):
    if not i.startsWith("#"):
      row = i.split("=")
      if name.startsWith(row[0]):
        if hash != "":
          discard 
            startProcess(
              command = "transmission-remote", 
              args = ["--torrent", hash, "--remove"]
            ).waitForExit()
        moveFile(name, "$dir/$name" % ["dir", row[1], "name", name])
        echo "moved $source to $dir/$name" % ["source", name, "dir", row[1], "name", name]
        return
  echo "torrent=$1 ignored" % [name]

proc move(name : string) =
  move(name, "")

var
  name: string
  hash: string

name = os.getEnv("TR_TORRENT_NAME")
hash = os.getEnv("TR_TORRENT_HASH")
if name != "" and hash != "":
  move(name, hash)
elif paramCount() > 0:
  move(paramStr(1))
else:
  echo "Usage: sortinghat <name>"