# Computer Interact Thing Installer
# NSIS Script for creating Windows installer

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"

# Define application name, version, and publisher
!define APP_NAME "Computer Interact Thing"
!define FLUTTER_BUILD_DIR "$%FLUTTER_BUILD_DIR%"
!define INSTALLER_OUTPUT_DIR "$%INSTALLER_OUTPUT_DIR%"
!define INSTALLER_FILENAME "$%INSTALLER_FILENAME%"
!define UNINSTALL_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

# Use fallback paths if environment variables not set
!ifndef FLUTTER_BUILD_DIR
  !define FLUTTER_BUILD_DIR "..\..\build\windows\runner\Release"
!endif
!ifndef INSTALLER_OUTPUT_DIR
  !define INSTALLER_OUTPUT_DIR "..\..\build\windows"
!endif
!ifndef INSTALLER_FILENAME
  !define INSTALLER_FILENAME "ComputerInteractInstaller.exe"
!endif

# Read version from pubspec.yaml or use default
!system 'powershell -Command "$version = \"1.0.0\"; try { if(Test-Path \"version.txt\") { $version = Get-Content \"version.txt\" } elseif(Test-Path \"..\..\pubspec.yaml\") { $version = (Get-Content \"..\..\pubspec.yaml\" | Select-String \"version:\") -replace \"version:\s*\", \"\" -replace \"\+.*\", \"\"; if(!$version) { $version = \"1.0.0\" } } } catch { Write-Host \"Error: $_\"; }; Write-Host \"Version: $version\"; Set-Content -Path \"version.txt\" -Value $version -Force"'
!define /file VERSION "version.txt"

# Set output file name and properties
Name "${APP_NAME}"

# Create output directory if it doesn't exist
!system 'powershell -Command "try { if(!(Test-Path -Path \"${INSTALLER_OUTPUT_DIR}\")) { New-Item -Path \"${INSTALLER_OUTPUT_DIR}\" -ItemType Directory -Force; Write-Host \"Created ${INSTALLER_OUTPUT_DIR} directory\" } } catch { Write-Host \"Error creating directory: $_\" }"'

# Use a simple fixed name without spaces or variables to avoid path issues
OutFile "${INSTALLER_OUTPUT_DIR}\${INSTALLER_FILENAME}"

# Create a file with the version info for reference
!system 'powershell -Command "try { Set-Content -Path \"${INSTALLER_OUTPUT_DIR}\installer_version.txt\" -Value \"${VERSION}\" -Force; Write-Host \"Saved version to ${INSTALLER_OUTPUT_DIR}\installer_version.txt\" } catch { Write-Host \"Error saving version: $_\" }"'

InstallDir "$PROGRAMFILES\${APP_NAME}"
InstallDirRegKey HKLM "${UNINSTALL_REG_KEY}" "InstallLocation"

# Request application privileges
RequestExecutionLevel admin

# Use the Modern UI
!define MUI_ABORTWARNING

# Try to use icons but don't fail if not found
!system 'powershell -Command "if(Test-Path \"..\..\windows\runner\resources\app_icon.ico\") { Write-Host \"Icon found\" } else { Write-Host \"Icon not found, using default\" }"'
!ifdef MUI_ICON
  !define MUI_ICON "..\..\windows\runner\resources\app_icon.ico"
  !define MUI_UNICON "..\..\windows\runner\resources\app_icon.ico"
!endif

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
      # Check if build files exist - check multiple possible locations
    IfFileExists "${FLUTTER_BUILD_DIR}\computer_interact_thing.exe" UseFlutterBuildDir 0
    IfFileExists "..\..\build\windows\runner\Release\computer_interact_thing.exe" UseStandardPath 0
    IfFileExists "..\..\build\windows\x64\runner\Release\computer_interact_thing.exe" UseX64Path NoFilesFound
      UseFlutterBuildDir:
        File "${FLUTTER_BUILD_DIR}\computer_interact_thing.exe"
        File "${FLUTTER_BUILD_DIR}\flutter_windows.dll"
        # Install additional DLLs that might be needed
        IfFileExists "${FLUTTER_BUILD_DIR}\msvcp140.dll" 0 +2
        File "${FLUTTER_BUILD_DIR}\msvcp140.dll"
        IfFileExists "${FLUTTER_BUILD_DIR}\vcruntime140.dll" 0 +2
        File "${FLUTTER_BUILD_DIR}\vcruntime140.dll"
        IfFileExists "${FLUTTER_BUILD_DIR}\vcruntime140_1.dll" 0 +2
        File "${FLUTTER_BUILD_DIR}\vcruntime140_1.dll"
        IfFileExists "${FLUTTER_BUILD_DIR}\data\*.*" 0 +2
        File /r "${FLUTTER_BUILD_DIR}\data"
        Goto ContinueAfterInstall
        
    UseStandardPath:
        File "..\..\build\windows\runner\Release\computer_interact_thing.exe"
        File "..\..\build\windows\runner\Release\flutter_windows.dll"
        # Install additional DLLs that might be needed
        IfFileExists "..\..\build\windows\runner\Release\msvcp140.dll" 0 +2
        File "..\..\build\windows\runner\Release\msvcp140.dll"
        IfFileExists "..\..\build\windows\runner\Release\vcruntime140.dll" 0 +2
        File "..\..\build\windows\runner\Release\vcruntime140.dll"
        IfFileExists "..\..\build\windows\runner\Release\vcruntime140_1.dll" 0 +2
        File "..\..\build\windows\runner\Release\vcruntime140_1.dll"
        IfFileExists "..\..\build\windows\runner\Release\data\*.*" 0 +2
        File /r "..\..\build\windows\runner\Release\data"
        Goto ContinueAfterInstall
        
    UseX64Path:
        File "..\..\build\windows\x64\runner\Release\computer_interact_thing.exe"
        File "..\..\build\windows\x64\runner\Release\flutter_windows.dll"
        # Install additional DLLs that might be needed
        IfFileExists "..\..\build\windows\x64\runner\Release\msvcp140.dll" 0 +2
        File "..\..\build\windows\x64\runner\Release\msvcp140.dll"
        IfFileExists "..\..\build\windows\x64\runner\Release\vcruntime140.dll" 0 +2
        File "..\..\build\windows\x64\runner\Release\vcruntime140.dll"
        IfFileExists "..\..\build\windows\x64\runner\Release\vcruntime140_1.dll" 0 +2
        File "..\..\build\windows\x64\runner\Release\vcruntime140_1.dll"
        IfFileExists "..\..\build\windows\x64\runner\Release\data\*.*" 0 +2
        File /r "..\..\build\windows\x64\runner\Release\data"
        Goto ContinueAfterInstall
              NoFilesFound:
        # Create a failure marker for diagnostic purposes
        !system 'powershell -Command "try { Set-Content -Path \"${INSTALLER_OUTPUT_DIR}\installer_build_failed.txt\" -Value \"Failed to find executable. Checked: ${FLUTTER_BUILD_DIR}, ..\\..\\build\\windows\\runner\\Release, ..\\..\\build\\windows\\x64\\runner\\Release\" -Force } catch { Write-Host \"Error writing failure marker: $_\" }"'
        
        # Show more detailed error message
        MessageBox MB_OK|MB_ICONSTOP "Error: Flutter build files not found.$\r$\n$\r$\nChecked locations:$\r$\n- ${FLUTTER_BUILD_DIR}$\r$\n- ..\..\build\windows\runner\Release$\r$\n- ..\..\build\windows\x64\runner\Release$\r$\n$\r$\nPlease build the application with 'flutter build windows' before running the installer."        Abort
        
    ContinueAfterInstall:
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
    
    # Create a success marker file
    !system 'powershell -Command "try { Set-Content -Path \"${INSTALLER_OUTPUT_DIR}\installer_success.txt\" -Value \"Installer build completed successfully at $(Get-Date)\" -Force } catch { Write-Host \"Error writing success marker: $_\" }"'
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