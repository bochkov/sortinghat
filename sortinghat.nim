import os
import osproc
import ospaths
import strutils

type
  Row = ref object of RootObj
    line : string

  Source = ref object of RootObj
    dir : string
    file : string

  Move = ref object of RootObj
    source : string

  StopTransmission = ref object of Move
    hash : string
    origin : Move

  Target = ref object of Move
    origin : Move

proc newRow(line : string) : Row =
  new result
  result.line = line

proc isEmpty(row : Row) : bool =
  return row.line == "" or row.line.startsWith("#")

proc match(row : Row, source : string) : bool = 
  var elems : seq[string] = row.line.split("=")
  return elems.len > 1 and source.splitFile().name.startsWith(elems[0])

proc toKV(row : Row) : tuple[key : string, dir : string] =
  var elems : seq[string] = row.line.split("=")
  if elems.len == 2:
    return (elems[0], elems[1])
  else:
    raise newException(OSError, "Cannot get key-value")

method move(this : Move, target : string) {.base.} =
  echo "try to move $1 to $2" % [this.source, target]
  discard execCmd("mv $1 $2" % [this.source, target])
  echo "moved $1 to $2" % [this.source, target]

method move(this : StopTransmission, target : string) =
  if this.hash != "":
    discard execCmd("transmission-remote --torrent $1 --remove" % this.hash)
  this.origin.move(target)

method move(this : Target, target : string = "") =
    var settings : string = readFile("$1/settings.ini" % getAppDir())
    var row : Row
    for line in settings.split("\n"):
      row = newRow(line)
      if not row.isEmpty() and row.match(this.origin.source):
        this.origin.move(row.toKV().dir)
        break

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
    Target(
      origin:
        StopTransmission(
          hash : getEnv("TR_TORRENT_HASH"),
          origin:
            Move(
              source : 
                Source().eval()
            )
        )
    ).move()
  except:
    discard
