import QtCore/gen_qvariant
import QtWidgets/[gen_qkeysequenceedit, gen_qwidget]

import kshortcutwidget

proc create_general_tab*(): QWidget =
  var tab = create QWidget

  # TODO: populate
  var idk = newKShortcutWidget(cast[ptr RealQWidget](addr tab))

  tab
