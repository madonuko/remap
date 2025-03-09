## Parser for keyd configuration files
##
## See <https://github.com/rvaiya/keyd/blob/master/docs/keyd.scdoc>
## or `man 'keyd(1)'`.

import std/[pegs, strutils, tables]
import npe

type
  KeydConfig* = ref object of RootObj
    ids*: KeydConfIds
  KeydConfIds* = object of RootObj
    whitelist*: bool


const parser = peg("KeydConf", conf: KeydConfig):
  KeydConf <- IdSection * *Section

  # whitespace or comments, must end with \n
  ign <- *(ign_once * '\n')
  ign_once <- *((Space) - '\n') | ('#' * *(1 - '\n'))
  line_end <- ?ign_once * '\n'

  IdSection <- ign * "[id]" * line_end * (IdSectBodyWhite | IdSectBodyBlack)
  IdSectBodyBlack <- *(Space) * '*' * line_end * *(?('-'*Id)*line_end)
  IdSectBodyWhite <- *(?(Id)*line_end)
  Id <- ?("k:" | "m:") * Xdigit[4] * ':' * Xdigit[4]

  Section <- ign * '['*SectionName*']' * line_end * SectionBody
  SectionName <- +LayerNameCh * *('+' * +LayerNameCh) * ?(':' * ModifierSet)
  LayerNameCh <- Alnum + '_'
  ModifierSet <- Modifier * *('-' * Modifier)
  Modifier <- {'C', 'M', 'A', 'S', 'G'}

  SectionBody <- *(?(SectionEntry) * line_end)
  SectionEntry <- Key * *Space * '=' * *Space * (Key | Macro | Action)

  KeyCh <- { '`', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '+', '=', '[', ']', '{', '}', '|', ';', ':', '\'', '"', ',', '<', '.', '>', '/', '?', '\\' }
  Key <- (+Alnum | KeyCh) * *('+'*(+Alnum | KeyCh))

  Macro <- 1 | Macro2 | *(Modifier * '-') * Key
  Macro2 <- "macro(" * MacroExp * ')'
  MacroExp <- Token * *((Space - '\n') * Token)
  Token <- Key | Macro2 | Timeout | *(1 - Space)
  Timeout <- +Digit * "ms"
  Action <- ActLayer | ActOneshot | ActSwap | ActSetlayout | ActClear | ActToggle | ActLayerm | ActOneshotm | ActSwapm | ActTogglem | ActClearm | ActOverload | ActOverloadt | ActOverloadt2 | ActOverloadi | ActLettermod | ActTimeout | ActMacro2 | ActCommand | ActNoop | BadAct
  BadAct <- (Alpha | '_') * *(Alnum | '_') * '(' * *1
  param(inner) <- *Space * inner * *Space
  ActLayer <- "layer(" * param(+LayerNameCh) * ')'
  ActOneshot <- "oneshot(" * param(+LayerNameCh) * ')'
  ActSwap <- "swap(" * param(+LayerNameCh) * ')'
  ActSetlayout <- "setlayout(" * param(+LayerNameCh) * ')'
  ActClear <- "clear()"
  ActToggle <- "toggle(" * param(+LayerNameCh) * ')'
  ActLayerm <- "layerm(" * param(+LayerNameCh) * ',' * *Space * MacroExp * *Space * ')'
  ActOneshotm <- "oneshotm(" * param(+LayerNameCh) * ',' * *Space * MacroExp * *Space * ')'
  ActSwapm <- "swapm(" * param(+LayerNameCh) * ',' * *Space * MacroExp * *Space * ')'
  ActTogglem <- "togglem(" * param(+LayerNameCh) * ',' * *Space * MacroExp * *Space * ')'
  ActClearm <- "clearm(" * *Space * MacroExp * *Space * ')'
  ActOverload <- "overload(" * param(+LayerNameCh) * Action * *Space * ')'
  ActOverloadt <- "overloadt(" * param(+LayerNameCh) * Action * *Space * ',' * *Space * Timeout * *Space * ')'

# NOTE: https://nim-lang.org/docs/pegs.html#peg-syntax-and-semantics-peg-construction
# since we are using `const`, this will not pull in PEG into our binary.
const peg: Peg =
  peg"""
KeydConf <- Section*

comment <- '#' (!\n .)*

Section <- '[' LayerName (':' Modifiers)? ']' comment? \n*?

LayerName <- \ident

Modifiers <- Modifier ('-' Modifier)*
Modifier <- 'C' / 'M' / 'A' / 'S' / 'G'
"""

var
  pStack: seq[string] = @[]
  valStack: seq[float] = @[]
  opStack = ""
let parseArithExpr = peg.eventParser:
  pkNonTerminal:
    enter:
      pStack.add p.nt.name
    leave:
      pStack.setLen pStack.high
      if length > 0:
        let matchStr = s.substr(start, start + length - 1)
        case p.nt.name
        of "Value":
          try:
            valStack.add matchStr.parseFloat
            echo valStack
          except ValueError:
            discard
        of "Sum", "Product":
          try:
            let val = matchStr.parseFloat
          except ValueError:
            if valStack.len > 1 and opStack.len > 0:
              valStack[^2] =
                case opStack[^1]
                of '+':
                  valStack[^2] + valStack[^1]
                of '-':
                  valStack[^2] - valStack[^1]
                of '*':
                  valStack[^2] * valStack[^1]
                else:
                  valStack[^2] / valStack[^1]
              valStack.setLen valStack.high
              echo valStack
              opStack.setLen opStack.high
              echo opStack
  pkChar:
    leave:
      if length == 1 and "Value" != pStack[^1]:
        let matchChar = s[start]
        opStack.add matchChar
        echo opStack
