import NimQml
import ui/remap_key_seq

# miqt
import QtWidgets/[gen_qapplication, gen_qpushbutton]
import strformat

proc mainProc() =
  var app = newQApplication()
  defer:
    app.delete()

  var engine = newQQmlApplicationEngine()
  defer:
    engine.delete()

  var remapKeySeq = newRemapKeySeq()
  defer:
    delete remapKeySeq
  var vRemapKeySeq = newQVariant remapKeySeq
  defer:
    delete vRemapKeySeq
  engine.setRootContextProperty("remapKeySeq", vRemapKeySeq)

  engine.load("qmls/main.qml")
  app.exec()

proc mainProcMiqt() =
  let app = gen_qapplication.QApplication.create()

  let btn = QPushButton.create("Hello world!")
  btn.setFixedWidth(320)

  var counter = 0

  btn.onPressed(
    proc() =
      counter += 1
      btn.setText(&"You have clicked the button {counter} time(s)")
  )

  btn.show()

  echo gen_qapplication.QApplication.exec()


when isMainModule:
  mainProcMiqt()

