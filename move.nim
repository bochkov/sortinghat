import osproc
import strutils

type
  Move* = ref object of RootObj
    source : string

proc newMove*(source : string) : Move =
  new result
  result.source = source

method src*(this : Move) : string {.base.} =
  return this.source

method move*(this : Move, target : string) {.base.} =
  echo "try to move $1 to $2" % [this.source, target]
  discard execCmd("mv $1 $2" % [this.source, target])
  echo "moved $1 to $2" % [this.source, target]