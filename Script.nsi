; ============================================================
; NSIS Modern User Interface Installer Script for XI Game
; Written by Joost Verburg (with modifications by Eden Server)
; Licensed under the ZLIB License
; 
; This installer script uses MUI2 to provide a modern installer
; experience. It installs prerequisites, game files, writes registry
; settings, registers DLLs, creates shortcuts, and builds an uninstaller.
; ============================================================

;--------------------------------
; Include MUI2 and other NSIS libraries

  !include "MUI2.nsh"              ; Modern UI 2 macros
  !include "LogicLib.nsh"          ; Logic macros for conditional processing
  !include "FileFunc.nsh"          ; File functions
  !include "StrContains.nsh"       ; String functions

  ; Define installer icons and bitmaps
  !define MUI_ICON "installer.ico"
  !define MUI_LANGDLL_WINDOWTITLE "Installer"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "background.bmp"
  !define MUI_WELCOMEPAGE_TITLE "Installer"

  ; Enable license page checkbox
  !define MUI_LICENSEPAGE_CHECKBOX

  ; Add plugin directories
  !addplugindir "..\Release"
  !addplugindir "."

;--------------------------------
; General Installer Settings

  ; Name and output file of the installer
  Name "XI Game"
  OutFile "XIInstaller.exe"

  ; Default installation folder
  InstallDir "$PROGRAMFILES\PlayOnline"

  ; Get the installation folder from the registry if already installed
  InstallDirRegKey HKCU "Software\XIGAME" "InstallPath"

  ; Request administrator privileges (important for writing to HKLM)
  RequestExecutionLevel admin

;--------------------------------
; Interface Settings

  ; Show an abort warning if installation is cancelled
  !define MUI_ABORTWARNING

;--------------------------------
; Installer Pages Setup

; --- Custom Page: DependenciesPage ---
; This function installs necessary prerequisites such as Visual Studio redistributables,
; .NET frameworks, and enables the DirectPlay feature.
Function DependenciesPage
  ; Extract and execute Visual Studio 2010 installer
  File /oname=$TEMP\VS2010.exe VS2010.exe
  ExecWait "$TEMP\VS2010.exe /install /passive /norestart"

  ; Extract and execute Visual Studio 2012 installer
  File /oname=$TEMP\VS2012.exe VS2012.exe
  ExecWait "$TEMP\VS2012.exe /install /passive /norestart"

  ; Extract and execute Visual Studio 2013 installer
  File /oname=$TEMP\VS2013.exe VS2013.exe
  ExecWait "$TEMP\VS2013.exe /install /passive /norestart"

  ; Extract and execute Visual Studio 2015 installer
  File /oname=$TEMP\VS2015.exe VS2015.exe
  ExecWait "$TEMP\VS2015.exe /install /passive /norestart"

  ; Extract and execute .NET Framework 4.0 Full installer
  File /oname=$TEMP\dotNetFx40_Full_x86_x64.exe dotNetFx40_Full_x86_x64.exe
  ExecWait "$TEMP\dotNetFx40_Full_x86_x64.exe /install /passive /norestart"

  ; Extract and execute .NET Framework 4.5 installer
  File /oname=$TEMP\dotNet45.exe dotNet45.exe
  ExecWait "$TEMP\dotNet45.exe /install /passive /norestart"

  ; Enable DirectPlay using DISM (for Windows features)
  nsExec::Exec "dism /online /Enable-Feature /FeatureName:DirectPlay /All"
FunctionEnd

; --- Leave Function for DependenciesPage ---
; This function could be used for form validation or cleanup after the dependencies page.
Function DependenciesLeave
  ; Placeholder for potential form validation.
  ; To read values from an options file, use:
  ; !insertmacro MUI_INSTALLOPTIONS_READ $Var "InstallOptionsFile.ini" ...
FunctionEnd

; --- Define Installer Pages ---
  !insertmacro MUI_PAGE_WELCOME                    ; Welcome page
  !insertmacro MUI_PAGE_LICENSE "license.txt"       ; License agreement page
  Page Custom DependenciesPage DependenciesLeave    ; Custom dependencies page with leave function
  !insertmacro MUI_PAGE_DIRECTORY                 ; Installation directory selection page
  !insertmacro MUI_PAGE_INSTFILES                 ; Installation progress page
  !insertmacro MUI_PAGE_FINISH                    ; Finish page

; --- Define Uninstaller Pages (if needed) ---
  ;!insertmacro MUI_UNPAGE_WELCOME
  ;!insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES              ; Uninstallation progress page
  !insertmacro MUI_UNPAGE_FINISH                 ; Uninstallation finish page

;--------------------------------
; Languages

  !insertmacro MUI_LANGUAGE "English"          ; Set the installer language

;--------------------------------
; Main Installer Section

Section "XIInstaller" XIInstaller
  ; Pre-calculate required disk space (approximate)
  AddSize 14000000

  ; Set the installation output directory
  SetOutPath "$INSTDIR"

  ; --- Copy Installer Icon ---
  File installer.ico

  ; --- Extract Game Files ---
  DetailPrint "Extracting game files, please wait..."
  ${GetExePath} $R0 ; Get the path of the installer executable
  ; Use the Nsis7z plugin to extract game data from data.pak with progress details
  Nsis7z::ExtractWithDetails "$R0\data.pak" "Installing game files %s..."

  ; --- Update Registry Settings ---
  DetailPrint "Updating registry settings..."
  
  SetRegView 64  ; Set registry view to 64-bit

  ; Store the installation folder in the registry
  WriteRegStr HKCU "Software\XIGAME" "InstallPath" "$INSTDIR"

  ; Register application for Windows Add/Remove Programs (Uninstall information)
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\XIGAME" "DisplayName" "Uninstall XI"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\XIGAME" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\XIGAME" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\XIGAME" "InstallLocation" "$\"$INSTDIR$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\XIGAME" "DisplayIcon" "$\"$INSTDIR\installer.ico$\""

  ; --- Write Additional Registry Settings ---
  ; These registry keys appear to be used by the PlayOnlineUS system and the game.
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS" "CommonFilesFolder" "C:\\Program Files\\Common Files\\"
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder" "1000" "$INSTDIR\PlayOnlineViewer"
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder" "0001" "$INSTDIR\FINAL FANTASY XI"
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\Interface" "1000" "001b1394"
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\Interface" "" ""
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\Interface" "0001" "0"

  ; Write SquareEnix game-specific registry settings (various configuration values)
  WriteRegStr HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "bFirst" "00"
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0022" 1
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0034" 1

  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0000" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0001" 0x00000640
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0002" 0x00000384
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0003" 0x00000640
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0004" 0x00000384
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0007" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0011" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0017" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0018" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0019" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0020" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0021" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0023" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0024" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0028" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0029" 0x0000000c
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0030" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0031" 0x3bc49ba6
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0032" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0033" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0035" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0036" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0037" 0x00000640
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0038" 0x00000384
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0039" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0040" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0041" 0x00000000
  WriteRegStr   HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0042" "$INSTDIR\FINAL FANTASY XI"
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "0043" 0x00000000
  WriteRegBin   HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "bFirst" 00
  WriteRegStr   HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "padsin000" "8,9,13,12,10,0,1,3,2,15,-1,-1,14,-33,-33,32,32,-36,-36,35,35,6,7,5,4,11,-1"
  WriteRegStr   HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\FinalFantasyXI" "padmode000" "1,0,1,0,1,1"

  ; Additional settings for PlayOnlineViewer (e.g., first boot, display settings, controller settings)
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer" "FirstBootPlayMovie" 0
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "FullScreen" 0
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "Language" 1
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "PlayAudio" 1
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "PlayOpeningMovie" 1
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "ResetSettings" 0
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "SupportLanguage" 1
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "UseGameController" 0
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "WindowH" 480
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings" "WindowW" 640

  ; Controller configuration settings
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "AnchorDown" 0x00000034
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "AnchorLeft" 0x00000036
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "AnchorRight" 0x00000032
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "AnchorUp" 0x00000030
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "Cancel" 0x00000002
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "ChrCsrNext" 0x00000007
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "ChrCsrPrev" 0x00000006
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "ID" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "Menu" 0x00000000
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "Navi" 0x00000003
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "Ok" 0x00000001
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "PageNext" 0x00000005
  WriteRegDWORD HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\Settings\Controller" "PagePrev" 0x00000004

  ; System information keys (binary data)
  WriteRegBin HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS\SquareEnix\PlayOnlineViewer\SystemInfo\QCheck" "LastMeasurementTime" ""

  ; --- Register DLLs ---
  DetailPrint "Registering libraries..."
  RegDLL "$INSTDIR\FINAL FANTASY XI\FFXi.dll"
  RegDLL "$INSTDIR\FINAL FANTASY XI\FFXiMain.dll"
  RegDLL "$INSTDIR\FINAL FANTASY XI\FFXiResource.dll"
  RegDLL "$INSTDIR\FINAL FANTASY XI\FFXiVersions.dll"

  RegDLL "$INSTDIR\PlayOnlineViewer\polhook.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\unicows.dll"
  
  RegDLL "$INSTDIR\PlayOnlineViewer\patchfiles\PlayOnlineViewer\viewer\com\app.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\patchfiles\PlayOnlineViewer\viewer\com\polcore.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\polcfg\sysinfo.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\util\unicows.dll"

  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\ax\MSVCR71.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\ax\polmvf.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\ax\polmvfINT.dll"

  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\com\app.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\com\polcore.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\contents\PolContents.dll"
  RegDLL "$INSTDIR\PlayOnlineViewer\viewer\contents\polcontentsINT.dll"

  RegDLL "$INSTDIR\TetraMaster\TM.dll"

  ; --- Create the Uninstaller ---
  DetailPrint "Creating Uninstaller..."
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; --- Create Shortcuts ---
  DetailPrint "Building Shortcuts..."
  ; Create a desktop shortcut for the game launcher (Ashita)
  SetOutPath "$INSTDIR\Ashita\"
  CreateShortCut "$DESKTOP\Play XI.lnk" "$INSTDIR\Ashita\Ashita-cli.exe" "server.ini"

  ; Create a Start Menu shortcut
  createDirectory "$SMPROGRAMS\XIGAME"
  createShortCut "$SMPROGRAMS\XIGAME\Play XI.lnk" "$INSTDIR\Ashita\Ashita-cli.exe" "server.ini"

SectionEnd

;--------------------------------
; Uninstaller Section

Section "Uninstall"
  ; Set the output path to the installation directory
  SetOutPath "$INSTDIR"

  ; Unregister DLLs in reverse order of registration
  UnRegDLL "$INSTDIR\FINAL FANTASY XI\FFXi.dll"
  UnRegDLL "$INSTDIR\FINAL FANTASY XI\FFXiMain.dll"
  UnRegDLL "$INSTDIR\FINAL FANTASY XI\FFXiResource.dll"
  UnRegDLL "$INSTDIR\FINAL FANTASY XI\FFXiVersions.dll"

  UnRegDLL "$INSTDIR\PlayOnlineViewer\polhook.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\unicows.dll"
  
  UnRegDLL "$INSTDIR\PlayOnlineViewer\patchfiles\PlayOnlineViewer\viewer\com\app.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\patchfiles\PlayOnlineViewer\viewer\com\polcore.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\polcfg\sysinfo.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\util\unicows.dll"

  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\ax\MSVCR71.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\ax\polmvf.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\ax\polmvfINT.dll"

  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\com\app.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\com\polcore.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\contents\PolContents.dll"
  UnRegDLL "$INSTDIR\PlayOnlineViewer\viewer\contents\polcontentsINT.dll"

  UnRegDLL "$INSTDIR\TetraMaster\TM.dll"

  ; Remove the installation directory and its contents recursively
  RMDir /r "$INSTDIR\"
  ; Delete the desktop shortcut
  Delete "$DESKTOP\Play XI.lnk"
  ; Remove the Start Menu directory
  RMDir /r "$SMPROGRAMS\XIGAME"

  ; Delete installer registry keys
  DeleteRegKey /ifempty HKCU "Software\XIINSTALLER"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\XIINSTALLER"
  DeleteRegKey HKLM "SOFTWARE\WOW6432Node\PlayOnlineUS"

SectionEnd
