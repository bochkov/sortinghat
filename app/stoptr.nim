import osproc
import strutils
import "move"

type
  StopTransmission = ref object of Move
    hash : string
    origin : Move

proc newStopTR*(hash : string, origin : Move) : StopTransmission =
  new result
  result.hash = hash
  result.origin = origin

method src*(this : StopTransmission) : string =
  return this.origin.src()
  
method move*(this : StopTransmission, target : string) =
  if this.hash != "":
    discard execCmd("transmission-remote --torrent $1 --remove" % this.hash)
  this.origin.move(target)