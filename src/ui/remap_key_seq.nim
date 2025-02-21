import QtWidgets/gen_qkeysequenceedit

import NimQml

{.passc: gorge("pkg-config --cflags Qt6Widgets").}
{.passl: gorge("pkg-config --libs Qt6Widgets").}

proc isKeyUnknown(
  key: int
): bool {.importcpp: "remap::isKeyUnknown(#)", header: "ui/remap_key_seq.cpp".}

proc keysToString(
  key: int, modifiers: int
): cstring {.importcpp: "remap::keyToString(#, #)", header: "ui/remap_key_seq.cpp".}

QtObject:
  type RemapKeySeq* = ref object of QObject

  proc delete(self: RemapKeySeq) =
    # self.QObject.delete
    discard

  proc setup(self: RemapKeySeq) =
    # self.QObject.setup
    discard

  proc newRemapKeySeq*(): RemapKeySeq =
    new(result, delete)
    result.setup

  # proc getName*(self: RemapKeySeq): string {.slot.} =
  #   result = self.m_name

  proc isKeyUnknown*(self: RemapKeySeq, key: int): bool {.slot.} =
    isKeyUnknown key

  proc keyToString*(self: RemapKeySeq, key: int, modifiers: int): string {.slot.} =
    $keysToString(key, modifiers)

  # proc setName*(self: RemapKeySeq, name: string) {.slot.} =
  #   if self.m_name == name:
  #     return
  #   self.m_name = name
  #   self.nameChanged(name)
  #
  # QtProperty[string] name:
  #   read = getName
  #   write = setName
  #   notify = nameChanged
