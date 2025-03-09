# Package

version       = "0.1.0"
author        = "madonuko"
description   = "⌨ A keyd GUI frontend for remapping your keys"
license       = "MIT"
srcDir        = "src"
bin           = @["remap"]

backend       = "cpp"

# Dependencies

requires "nim >= 2.0.0"
#requires "nimqml >= 0.9.0"
requires "sweet"
requires "npeg"
