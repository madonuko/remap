when findExe("mold").len > 0 and defined(linux):
  switch("passL", "-fuse-ld=mold")

--path:"../vendor/miqt6/"
--path:"../vendor/miqt6/QtCore"
--path:"../vendor/miqt6/QtGui"
--path:"../vendor/miqt6/QtNetwork"
--path:"../vendor/miqt6/QtQml"
--path:"../vendor/miqt6/QtWidgets"
