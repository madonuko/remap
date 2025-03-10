import std/sugar
import vendor/nimsutils/src/nimsutils

proc main =
  run "nim c --noLinking --noMain --nimcache:build keyd_parser/keyd_parser.nim"
  run "nimble build --noLinking --nimcache:build"
  let links = run("jq -r '.link[]' build/keyd_parser.json; jq -r '.link[]' build/remap.json").output
  let compileCommand = run("jq -r '.linkcmd' build/remap.json").output
  
  var ls: seq[string] = @[]
  var fs: seq[string] = @[]
  
  for link in links.split('\n'):
    var f = link
    f.removeSuffix(".nim.c.o")
    f.removeSuffix(".nim.cpp.o")
    if ls.contains f:
      debug "Ignoring duplicated {f}".fmt
      continue
    ls.add f
    fs.add link

  run compileCommand & " -fuse-ld=mold -Xlinker -z -Xlinker muldefs " & fs.join(" ")

  info "remap compiled successfully"

main()
