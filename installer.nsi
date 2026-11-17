Unicode true
Name "SCAFFOLDING SIMULATOR 3.0"
OutFile "dist/SCAFFOLDING-SIMULATOR-3.0-SETUP.exe"
InstallDir "$LOCALAPPDATA\SCAFFOLDING SIMULATOR"
RequestExecutionLevel user
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles
Section
 SetOutPath "$INSTDIR"
 File "dist/SCAFFOLDING-SIMULATOR.exe"
 WriteUninstaller "$INSTDIR\Uninstall.exe"
 CreateShortcut "$DESKTOP\SCAFFOLDING SIMULATOR.lnk" "$INSTDIR\SCAFFOLDING-SIMULATOR.exe"
SectionEnd
Section "Uninstall"
 Delete "$DESKTOP\SCAFFOLDING SIMULATOR.lnk"
 Delete "$INSTDIR\SCAFFOLDING-SIMULATOR.exe"
 Delete "$INSTDIR\Uninstall.exe"
 RMDir "$INSTDIR"
SectionEnd
