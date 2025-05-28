# 🖱️ Computer Interact Thing - Imperial Mouse Tracking System

[![Flutter Desktop CI](https://github.com/tgor152/computer-interact-thing/actions/workflows/flutter-desktop-ci.yml/badge.svg)](https://github.com/tgor152/computer-interact-thing/actions/workflows/flutter-desktop-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)

> **🤖 AI-Powered Development**: This project has been **fully developed by GitHub Copilot Agent** as a demonstration of AI-assisted software development capabilities. Every line of code, UI design, and feature implementation was generated through natural language conversations with the AI assistant, showcasing the potential of human-AI collaboration in modern software development.

## 🎯 What This Application Does

The **Computer Interact Thing** is a real-time mouse tracking application with a sleek Star Wars Imperial-themed dashboard interface. It monitors and analyzes your mouse interactions on Windows systems, providing detailed analytics and insights into your cursor behavior.

### ✨ Key Features

- **🔄 Real-time Mouse Tracking**: Continuously monitors mouse movements and click events
- **📊 Interactive Dashboard**: Star Wars Imperial-themed UI with glowing effects and sci-fi styling
- **📈 Analytics & Metrics**: 
  - Total movements tracked
  - Click interaction count
  - Distance traveled (in pixels)
  - Live cursor coordinates
  - Real-time system status
- **📋 Data Export**: Export all tracking data to Excel (.xlsx) format
- **⚡ High Performance**: 50ms polling rate for smooth, responsive tracking
- **🎨 Modern UI**: Built with Flutter's Material Design and Google Fonts (Orbitron)
- **🌙 Dark Theme**: Eye-friendly dark interface with neon accents

### 🛠️ Technical Implementation

- **Platform**: Windows Desktop Application (Flutter)
- **Backend**: Direct Windows API integration using `win32` package
- **UI Framework**: Flutter with Material Design 3
- **Fonts**: Google Fonts (Orbitron) for futuristic styling
- **Data Export**: Excel file generation with timestamps and coordinates
- **Architecture**: Real-time event-driven architecture with timer-based polling

## 📥 Download & Install

### For End Users (Recommended)

**Simply download the pre-built installer - no development setup required!**

1. **Download the Latest Release**
   - Go to [Releases](https://github.com/tgor152/computer-interact-thing/releases/latest)
   - Download `ComputerInteractInstaller.exe`

2. **Install & Run**
   - Run the downloaded installer as administrator
   - The app will be installed to your Program Files
   - Launch from Desktop shortcut or Start Menu

**System Requirements:** Windows 10/11 (no additional dependencies needed)

### For Developers

If you want to build from source or contribute to development, see the [Development & Contributing](#🛠️-development--contributing) section below.

## 🚀 How to Use

### 📋 Prerequisites

- **Windows 10/11** (Required for Windows API mouse tracking)
- **Flutter SDK 3.7.2+** installed and configured
- **Visual Studio Build Tools** or **Visual Studio Community** for Windows development

### 🔧 Installation & Setup (For Developers)

> **💡 End users:** If you just want to use the app, see the [Download & Install](#📥-download--install) section above instead.

1. **Clone the Repository**
   ```bash
   git clone https://github.com/tgor152/computer-interact-thing.git
   cd computer-interact-thing
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Enable Windows Desktop Support** (if not already enabled)
   ```bash
   flutter config --enable-windows-desktop
   ```

4. **Run the Application**
   ```bash
   flutter run -d windows
   ```

### 🎮 Using the Application

1. **Launch**: Start the application and you'll see the Imperial Tracking System dashboard
2. **Automatic Tracking**: Mouse movements and clicks are automatically tracked in real-time
3. **View Metrics**: Monitor your mouse activity through the dashboard cards:
   - Movements tracked
   - Click interactions
   - Distance moved
   - System status
4. **Export Data**: Click the export button (💾) in the top-right to save tracking data to Excel
5. **Real-time Updates**: All metrics update live as you interact with your computer

### 📊 Understanding the Data

- **Movements**: Each mouse position change is recorded with timestamp and coordinates
- **Clicks**: Left mouse button clicks are tracked with location data
- **Distance**: Calculated using Euclidean distance between consecutive mouse positions
- **Export**: Excel file contains columns: Timestamp, X-coordinate, Y-coordinate, Event Type

## 🛠️ Development & Contributing

### 🏗️ Development Setup

1. **Development Environment**
   ```bash
   # Install Flutter (if not already installed)
   # Follow: https://docs.flutter.dev/get-started/install/windows
   
   # Verify installation
   flutter doctor
   
   # Clone and setup project
   git clone https://github.com/tgor152/computer-interact-thing.git
   cd computer-interact-thing
   flutter pub get
   ```

2. **Code Analysis & Testing**
   ```bash
   # Run code analysis
   flutter analyze
   
   # Run tests
   flutter test
   
   # Run in debug mode
   flutter run -d windows --debug
   ```

3. **Building for Production**
   ```bash
   # Build release version
   flutter build windows --release
   
   # The executable will be in: build/windows/runner/Release/
   ```

### 🔧 Project Structure

```
lib/
├── main.dart           # Main application entry point and UI
pubspec.yaml           # Dependencies and project configuration
windows/               # Windows-specific build configuration
├── runner/           # Windows runner application
└── CMakeLists.txt    # CMake build configuration
.github/workflows/     # CI/CD pipeline configuration
└── flutter-desktop-ci.yml
```

### 📦 Key Dependencies

- **`flutter`**: UI framework
- **`win32`**: Windows API access for mouse tracking
- **`ffi`**: Foreign Function Interface for native API calls
- **`excel`**: Excel file generation and export
- **`google_fonts`**: Orbitron font for sci-fi styling
- **`flutter_glow`**: Glowing text effects
- **`path_provider`**: File system access for exports

### 🤝 Contributing Guidelines

1. **Fork the Repository**: Create your own fork to work on
2. **Create Feature Branch**: `git checkout -b feature/amazing-feature`
3. **Follow Code Style**: Use `flutter analyze` to ensure code quality
4. **Test Your Changes**: Run existing tests and add new ones if needed
5. **Update Documentation**: Keep README and code comments up to date
6. **Submit Pull Request**: Include detailed description of changes

### 🔍 Development Notes

- **Mouse Tracking**: Uses Windows `GetCursorPos()` API for precise coordinate tracking
- **Click Detection**: Monitors `VK_LBUTTON` state using `GetAsyncKeyState()`
- **Performance**: 50ms timer intervals balance responsiveness with CPU usage
- **Memory Management**: Uses FFI memory allocation/deallocation for native calls
- **State Management**: Simple setState() pattern for real-time UI updates

### 🐛 Known Issues & Limitations

- **Windows Only**: Currently only supports Windows due to Win32 API dependency
- **Background Tracking**: Only tracks when application is running
- **Permission Requirements**: No special permissions needed (uses standard Windows APIs)

### 🔮 Future Enhancements

- **Cross-platform Support**: Add macOS and Linux mouse tracking
- **Advanced Analytics**: Heat maps, usage patterns, productivity metrics
- **Data Visualization**: Charts and graphs for historical data
- **Hotkey Support**: Global hotkeys for start/stop tracking
- **Configuration Options**: Customizable polling rates and export formats

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **GitHub Copilot**: For the complete AI-powered development of this application
- **Flutter Team**: For the excellent cross-platform framework
- **Microsoft**: For the comprehensive Win32 API documentation
- **Star Wars Universe**: For the inspiring Imperial aesthetic theme

---

<div align="center">
  <i>🤖 Proudly crafted entirely by AI • No human code was harmed in the making of this application</i>
</div>
