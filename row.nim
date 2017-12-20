import os
import strutils

type
  Row* = ref object of RootObj
    line : string

proc newRow*(line : string) : Row =
  new result
  result.line = line

proc isEmpty*(row : Row) : bool =
  return row.line == "" or row.line.startsWith("#")

proc match*(row : Row, source : string) : bool = 
  var elems : seq[string] = row.line.split("=")
  return elems.len > 1 and source.splitFile().name.startsWith(elems[0])

proc toKV*(row : Row) : tuple[key : string, dir : string] =
  var elems : seq[string] = row.line.split("=")
  if elems.len == 2:
    return (elems[0], elems[1])
  else:
    raise newException(OSError, "Cannot get key-value")