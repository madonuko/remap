import npeg/codegen

type
  KeydConfig* {.exportc.} = object of RootObj
    ids*: KeydConfIds
    main*: KeydConfMain
    aliases*: KeydConfAliases

  KeydConfIds* {.exportc.} = object of RootObj
    whitelist*: bool
    ## for dev, 0 = Any, 1 = Mouse, 2 = Keyboard
    list*: seq[tuple[dev: cint, id: cstring]]

  KeydConfMain* {.exportc.} = object of RootObj
  KeydConfAliases* {.exportc.} = object of RootObj

proc parse*(cfg: cstring): tuple[cfg: KeydConfig, res: MatchResult[char]] {.importc.}

proc `$`*(cfg: KeydConfig): string =
  echo "KeydConfig" & $(ids: cfg.ids, main: cfg.main, aliases: cfg.aliases)
