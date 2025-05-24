# Computer Interact Thing Installer
# NSIS Script for creating Windows installer

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"

# Define application name, version, and publisher
!define APP_NAME "Computer Interact Thing"
!define FLUTTER_BUILD_DIR "..\..\build\windows\runner\Release"
!define UNINSTALL_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

# Read version from pubspec.yaml
!system 'powershell -Command "$version = (Get-Content ..\..\pubspec.yaml | Select-String \"version:\") -replace \"version:\s*\", \"\" -replace \"\+.*\", \"\"; if (!$version) { $version = \"1.0.0\" }; Write-Host \"Version detected: $version\"; Set-Content -Path \"version.txt\" -Value $version -Force"'
!define /file VERSION "version.txt"

# Set output file name and properties
Name "${APP_NAME}"
# Ensure the output directory exists
!system 'powershell -Command "if (!(Test-Path -Path \"..\..\build\windows\")) { New-Item -Path \"..\..\build\windows\" -ItemType Directory -Force; Write-Host \"Created build\windows directory\" }"'
# Use a simple fixed name without spaces or variables to avoid path issues
OutFile "..\..\build\windows\ComputerInteractInstaller.exe"
# Create a file with the version info for reference
!system 'powershell -Command "Set-Content -Path \"..\..\build\windows\installer_version.txt\" -Value \"${VERSION}\" -Force"'
InstallDir "$PROGRAMFILES\${APP_NAME}"
InstallDirRegKey HKLM "${UNINSTALL_REG_KEY}" "InstallLocation"

# Request application privileges
RequestExecutionLevel admin

# Use the Modern UI
!define MUI_ABORTWARNING
!define MUI_ICON "..\..\windows\runner\resources\app_icon.ico"
!define MUI_UNICON "..\..\windows\runner\resources\app_icon.ico"

# Define the UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Set the UI language
!insertmacro MUI_LANGUAGE "English"

# Installer section
Section "Install" SecInstall
    SetOutPath "$INSTDIR"
    
    # Check if the application is already installed
    ReadRegStr $0 HKLM "${UNINSTALL_REG_KEY}" "UninstallString"
    ${If} $0 != ""
        # Get current version
        ReadRegStr $1 HKLM "${UNINSTALL_REG_KEY}" "DisplayVersion"
        
        # Compare versions
        ${If} $1 == "${VERSION}"
            MessageBox MB_YESNO "Version ${VERSION} is already installed. Do you want to reinstall?" IDYES reinstall IDNO abort
            abort:
                Abort
            reinstall:
                # Run the uninstaller
                ExecWait '"$0" /S _?=$INSTDIR'
        ${Else}
            MessageBox MB_YESNO "Version $1 is already installed. Do you want to upgrade to version ${VERSION}?" IDYES upgrade IDNO abort
            upgrade:
                # Run the uninstaller
                ExecWait '"$0" /S _?=$INSTDIR'
        ${EndIf}
    ${EndIf}
    
    # Check if build files exist
    IfFileExists "${FLUTTER_BUILD_DIR}\computer_interact_thing.exe" BuildFilesExist
        MessageBox MB_OK "Error: Build files not found. Please build the application first with 'flutter build windows'"
        Abort
    BuildFilesExist:
    
    # Install new files
    File /r "${FLUTTER_BUILD_DIR}\*.*"
    
    # Create shortcut
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\computer_interact_thing.exe"
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\computer_interact_thing.exe"
    
    # Register the application
    WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "DisplayIcon" "$INSTDIR\computer_interact_thing.exe"
    WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "Publisher" "Computer Interact Thing Developer"
    WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "InstallLocation" "$INSTDIR"
    
    # Calculate size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "${UNINSTALL_REG_KEY}" "EstimatedSize" "$0"
    
    # Write uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

# Uninstaller section
Section "Uninstall"
    # Remove application files
    RMDir /r "$INSTDIR"
    
    # Remove shortcuts
    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    Delete "$DESKTOP\${APP_NAME}.lnk"
    
    # Remove registry keys
    DeleteRegKey HKLM "${UNINSTALL_REG_KEY}"
SectionEnd