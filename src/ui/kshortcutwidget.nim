import QtWidgets/gen_qwidget

{.passc: "-I/usr/include/KF6/KXmlGui/".}
{.passl: "-lKF6XmlGui".}
{.passc: gorge("pkg-config --cflags Qt6Gui Qt6Widgets").}
{.passc: gorge("pkg-config --libs Qt6Gui Qt6Widgets").}

type
  KShortcutWidget* {.importcpp: "KShortcutWidget", header: "<KShortcutWidget>".} = object of QObject
  RealQWidget* {.importcpp: "QWidget", header: "<QWidget>".} = object of QWidget

proc newKShortcutWidget*(
  parent: ptr RealQWidget
): KShortcutWidget {.
  importcpp: "KShortcutWidget::KShortcutWidget()",
  constructor,
  header: "<KShortcutWidget>"
.}
