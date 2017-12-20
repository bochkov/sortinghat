import os
import strutils
import "move", "row"

type
  Target = ref object of Move
    origin : Move
    settings : string

proc newTarget*(origin : Move, settings : string) : Target =
  new result
  result.origin = origin
  result.settings = settings

method src*(this : Target) : string =
  return this.origin.src()

method move*(this : Target, target : string = "") =
    var settings : string = readFile("$1/$2" % [getAppDir(), this.settings])
    var row : Row
    for line in settings.split("\n"):
      row = newRow(line)
      if not row.isEmpty() and row.match(this.src()):
        this.origin.move(row.toKV().dir)
        break