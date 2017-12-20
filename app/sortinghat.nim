import os
import strutils
import "move", "stoptr", "target"

type
  Source = ref object of RootObj
    dir : string
    file : string

proc eval(this : Source) : string =
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
    raise newException(OSError, "params not defined")
  return "$1/$2" % [dir, name]

if isMainModule:
  try:
    newTarget(
      settings = "settings.ini",
      origin =
        newStopTR(
          hash = getEnv("TR_TORRENT_HASH"),
          origin =
            newMove(
              source =
                Source().eval()
            )
        )
    ).move()
  except:
    discard
