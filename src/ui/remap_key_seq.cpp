//?
// https://stackoverflow.com/questions/64826271/how-to-use-qkeysequence-or-qkeysequenceedit-from-qml

#define QT_NO_KEYWORDS

#include <QtCore/QObject>
#include <QtGui/QKeySequence>

namespace remap {
bool isKeyUnknown(const int key) {
  // weird key codes that appear when modifiers
  // are pressed without accompanying standard keys
  constexpr int NO_KEY_LOW = 16777248;
  constexpr int NO_KEY_HIGH = 16777251;
  if (NO_KEY_LOW <= key && key <= NO_KEY_HIGH) {
    return true;
  }

  if (key == Qt::Key_unknown) {
    return true;
  }

  return false;
}
char *keyToString(const int key, const int modifiers) {
  if (!isKeyUnknown(key)) {
    return QKeySequence(key | modifiers).toString().toUtf8().data();
  } else {
    // Change to "Ctrl+[garbage]" to "Ctrl+_"
    QString modifierOnlyString =
        QKeySequence(Qt::Key_Underscore | modifiers).toString();

    // Change "Ctrl+_" to "Ctrl+..."
    modifierOnlyString.replace("_", "...");
    return modifierOnlyString.toUtf8().data();
  }
}
} // namespace remap
