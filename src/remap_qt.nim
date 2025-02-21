import QtCore/gen_qvariant
import QtQml/gen_qqmlapplicationengine
import QtWidgets/[gen_qapplication, gen_qpushbutton, gen_qkeysequenceedit]

proc main() =
  var app = QApplication.create()
  defer:
    app.delete()

  var engine = QQmlApplicationEngine.create()
  defer:
    engine.delete()

  let test = QKeySequenceEdit.create()
  defer:
    test.delete()
  discard
    engine.rootContext.setProperty("test", QVariant.fromValue(test))

  engine.load("qmls/main.qml")
  discard exec QApplication

when isMainModule:
  main()
