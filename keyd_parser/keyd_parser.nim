## Parser for keyd configuration files
##
## See <https://github.com/rvaiya/keyd/blob/master/docs/keyd.scdoc>
## or `man 'keyd(1)'`.

import std/[strutils, tables]
import npeg
import npeg/codegen

import header

const parser* = peg("KeydConf", conf: KeydConfig):
  KeydConf <- IdSection * *Section

  # whitespace or comments, must end with \n
  ign <- *(ign_once * '\n')
  ign_once <- *((Space) - '\n') | ('#' * *(1 - '\n'))
  line_end <- ?ign_once * '\n'

  IdSection <- ign * "[ids]" * line_end * ign * (IdSectBodyBlack | IdSectBodyWhite)
  IdSectBodyBlack <- '*' * line_end * *(?('-' * Id) * line_end)
  IdSectBodyWhite <- *(?(Id) * line_end)
  Id <- ?("k:" | "m:") * Xdigit[4] * ':' * Xdigit[4]

  Section <- ign * '[' * SectionName * ']' * line_end * SectionBody
  SectionName <- +LayerNameCh * *('+' * +LayerNameCh) * ?(':' * ModifierSet)
  LayerNameCh <- Alnum | '_'
  ModifierSet <- Modifier * *('-' * Modifier)
  Modifier <- {'C', 'M', 'A', 'S', 'G'}

  SectionBody <- *(?(SectionEntry) * line_end)
  SectionEntry <- Key * *Space * '=' * *Space * (Key | Macro | Action)

  KeyCh <- {
    '`', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '+', '=', '[',
    ']', '{', '}', '|', ';', ':', '\'', '"', ',', '<', '.', '>', '/', '?', '\\',
  }
  Key <- (+Alnum | KeyCh) * *('+' * (+Alnum | KeyCh))

  Macro <- 1 | Macro2 | *(Modifier * '-') * Key
  Macro2 <- "macro(" * MacroExp * ')'
  MacroExp <- Token * *((Space - '\n') * Token)
  Token <- Key | Macro2 | Timeout | *(1 - Space)
  Timeout <- +Digit * "ms"

  Action <-
    ActLayer | ActOneshot | ActSwap | ActSetlayout | ActClear | ActToggle | ActLayerm |
    ActOneshotm | ActSwapm | ActTogglem | ActClearm | ActOverload | ActOverloadt |
    ActOverloadt2 | ActOverloadi | ActLettermod | ActTimeout | ActMacro2 | ActCommand |
    ActNoop | BadAct
  BadAct <- (Alpha | '_') * *(Alnum | '_') * '(' * *1
  param(inner) <- *Space * inner * *Space
  ActLayer <- "layer(" * param(+LayerNameCh) * ')'
  ActOneshot <- "oneshot(" * param(+LayerNameCh) * ')'
  ActSwap <- "swap(" * param(+LayerNameCh) * ')'
  ActSetlayout <- "setlayout(" * param(+LayerNameCh) * ')'
  ActClear <- "clear()"
  ActToggle <- "toggle(" * param(+LayerNameCh) * ')'
  ActLayerm <- "layerm(" * param(+LayerNameCh) * ',' * param(Macro) * ')'
  ActOneshotm <- "oneshotm(" * param(+LayerNameCh) * ',' * param(Macro) * ')'
  ActSwapm <- "swapm(" * param(+LayerNameCh) * ',' * param(Macro) * ')'
  ActTogglem <- "togglem(" * param(+LayerNameCh) * ',' * param(Macro) * ')'
  ActClearm <- "clearm(" * param(Macro) * ')'
  ActOverload <- "overload(" * param(+LayerNameCh) * ',' * param(Action) * ')'
  ActOverloadt <-
    "overloadt(" * param(+LayerNameCh) * ',' * param(Action) * ',' * param(Timeout) * ')'
  ActOverloadt2 <-
    "overloadt2(" * param(+LayerNameCh) * ',' * param(Action) * ',' * param(Timeout) *
    ')'
  ActOverloadi <-
    "overloadt(" * param(Action) * ',' * param(Action) * ',' * param(Timeout) * ')'
  ActLettermod <-
    "lettermod(" * param(+LayerNameCh) * ',' * param(Key) * ',' * param(Timeout) *
    param(Timeout) * ')'
  ActTimeout <-
    "timeout(" * param(Action) * ',' * param(Timeout) * ',' * param(Action) * ')'
  ActMacro2 <-
    "timeout2(" * param(Timeout) * ',' * param(Timeout) * ',' * param(Macro) * ')'
  ActCommand <- "command(" * *1 * ')'
  ActNoop <- "noop"

proc parse*(cfg: cstring): tuple[cfg: KeydConfig, res: MatchResult[char]] {.exportc.} =
  result.res = parser.match($cfg, result.cfg)

# assert parse(
#   """
# [ids]
#
# *
#
# [main]
# a = b
# """
# ).res.ok
