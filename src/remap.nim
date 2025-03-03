echo "Running remap…"

import std/os

import QtCore/gen_qvariant
# import QtQml/gen_qqmlapplicationengine
import
  QtWidgets/[
    gen_qapplication, gen_qpushbutton, gen_qkeysequenceedit, gen_qtabwidget,
    gen_qmessagebox,
  ]
import sweet

import ui/tab_general

proc checkForKeyd() =
  echo "checking for keyd"
  if !!findExe "keyd": return
  var dialog = create QMessageBox
  dialog.setIcon QMessageBoxIconEnum.Critical
  dialog.setText "Fatal Error"
  dialog.setInformativeText "Cannot find `keyd` in `$PATH`. Please install `keyd` and try again."
  dialog.setWindowTitle "remap"
  dialog.setStandardButtons QMessageBoxStandardButtonEnum.Close
  discard exec dialog
  quit 1

proc main() =
  echo "main"
  var app = QApplication.create()
  defer: app.delete()

  checkForKeyd()

  var tab = create QTabWidget
  discard tab.addTab(create_general_tab(), "General")
  show tab

  echo "exec QApplication"
  discard exec QApplication

when isMainModule:
  main()
