# Windows Installer for Computer Interact Thing

This directory contains the NSIS script used to create a Windows installer for the Computer Interact Thing application.

## Features

- Automatically creates installer with the version from pubspec.yaml
- Detects previous installations
- Manages upgrades and reinstallations
- Provides a lightweight UI for installation
- Adds Start Menu and Desktop shortcuts
- Properly registers the application for Add/Remove Programs

## How it Works

The installer script (`installer.nsi`) does the following:

1. Extracts the version number from pubspec.yaml
2. Checks for existing installations
3. Handles reinstallation or upgrade scenarios
4. Installs the application to Program Files
5. Creates necessary shortcuts
6. Registers the application in Windows

## Building Manually

If you need to build the installer manually:

1. Install NSIS (Nullsoft Scriptable Install System)
2. Build the Flutter Windows application: `flutter build windows`
3. Navigate to this directory: `cd windows/installer`
4. Run NSIS compiler: `makensis installer.nsi`

The installer will be created in the `build/windows` directory.