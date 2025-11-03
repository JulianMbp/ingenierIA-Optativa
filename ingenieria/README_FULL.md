# IngenierIA - Construction Management System

A Flutter application for construction project management with AI integration.

## 🏗️ Overview

IngenierIA is a comprehensive construction management system built with **Clean Architecture** principles. It connects to:

1. **NestJS Microservice** - Authentication and role management
2. **Supabase Database** - Project operational data (materials, logs, attendance)
3. **Ollama AI Service** - Report generation and intelligent summaries

## 🎯 Features

### Role-Based Access Control
- **Admin General** - Full system access
- **Admin Obra** - Project-level management
- **Encargado de Área** - Area/team management
- **Obrero** - Worker daily operations
- **SST** - Safety and health management
- **Compras** - Purchasing and materials
- **RRHH** - Human resources
- **Consultor** - Project consultation and reports

### Core Modules
- 📱 **Authentication** - JWT-based secure login
- 🏗️ **Project Selection** - Multi-project management
- 📦 **Materials Management** - Inventory and orders
- 📝 **Attendance Tracking** - Daily check-in/out with offline support
- 📋 **Work Logs** - Progress tracking and reporting
- 🦺 **Safety Incidents** - SST incident management
- 🤖 **AI Reports** - Automated report generation using Ollama
- 📊 **Dashboards** - Role-specific views and analytics

## 📁 Project Structure

```
lib/
┣ core/                    # Shared utilities and configurations
┃ ┣ config/               # API and app configuration
┃ ┣ constants/            # App-wide constants
┃ ┣ error/                # Error handling (failures & exceptions)
┃ ┣ theme/                # Material 3 theme configuration
┃ ┗ utils/                # Helper utilities and logger
┃
┣ data/                    # Data layer (models, repositories)
┃ ┣ models/               # Data models with JSON serialization
┃ ┣ repositories/         # Repository implementations
┃ ┗ local/                # Local database (Drift)
┃
┣ domain/                  # Business logic layer
┃ ┣ entities/             # Core business entities
┃ ┣ repositories/         # Repository interfaces
┃ ┗ usecases/             # Business use cases
┃
┣ presentation/            # UI layer
┃ ┣ auth/                 # Authentication module
┃ ┣ dashboard/            # Role-based dashboards
┃ ┣ project/              # Project selection
┃ ┣ materials/            # Materials management
┃ ┣ attendance/           # Attendance tracking
┃ ┣ providers/            # Riverpod state management
┃ ┗ widgets/              # Reusable UI components
┃
┣ services/                # External service clients
┃ ┣ nestjs_api_client.dart    # NestJS authentication API
┃ ┣ supabase_service.dart     # Supabase database operations
┃ ┗ ollama_ai_service.dart    # Ollama AI integration
┃
┗ main.dart                # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24 or higher
- Dart 3.0 or higher
- NestJS backend service running (for authentication)
- Supabase project configured
- Ollama running locally (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   cd ingenieria
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   
   Edit `lib/core/config/api_config.dart`:
   ```dart
   static const String nestJsBaseUrl = 'https://your-nestjs-api.com';
   static const String supabaseUrl = 'https://your-project.supabase.co';
   static const String supabaseAnonKey = 'your-supabase-anon-key';
   static const String ollamaBaseUrl = 'http://localhost:11434';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Code Generation

This project uses code generation for:
- Freezed (immutable models)
- JSON serialization
- Riverpod providers
- Drift (database)

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode for development:
```bash
flutter pub run build_runner watch
```

## 🔐 Authentication Flow

1. User enters email and password
2. App sends credentials to NestJS microservice
3. NestJS validates and returns JWT token
4. Token is stored securely using `flutter_secure_storage`
5. JWT payload contains:
   - `sub`: User ID
   - `rol`: User role
   - `obra_id`: Assigned project ID
6. Token is sent in headers for all API requests
7. If token expires, refresh token flow is triggered

## 📊 Database Schema (Supabase)

### Tables
- `obras` - Projects/construction sites
- `usuarios` - Users and roles
- `materiales` - Materials inventory
- `asistencias` - Attendance records
- `bitacora` - Work logs
- `incidentes_sst` - Safety incidents
- `documentos` - Generated reports and documents

## 🤖 AI Integration

### Ollama Setup

1. Install Ollama: https://ollama.ai
2. Pull a model (e.g., llama2):
   ```bash
   ollama pull llama2
   ```
3. Start Ollama server:
   ```bash
   ollama serve
   ```

### AI Features
- **Progress Reports** - Auto-generate from work logs
- **Safety Summaries** - Analyze safety incidents
- **Material Analysis** - Usage trends and recommendations
- **Custom Reports** - Flexible report generation

## 🎨 Theming

The app uses **Material 3** design with custom theming:
- Primary color: Blue (#1976D2)
- Success: Green (#388E3C)
- Warning: Orange (#FFA000)
- Error: Red (#D32F2F)

Consistent spacing and typography throughout.

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Technologies Used

- **Flutter 3.24+** - UI framework
- **Riverpod** - State management
- **Dio** - HTTP client for NestJS API
- **Supabase Flutter SDK** - Database operations
- **Drift** - Local SQLite database
- **flutter_secure_storage** - Secure token storage
- **jwt_decoder** - JWT token parsing
- **go_router** - Navigation
- **freezed** - Immutable models
- **equatable** - Value equality
- **dartz** - Functional programming (Either)

## 📝 Code Style

- All code, comments, and documentation in **English**
- File names: `snake_case`
- Variables/functions: `camelCase`
- Classes/widgets: `PascalCase`
- Follow Dart's effective style guide
- Meaningful doc comments for all public APIs

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Write tests for new features
3. Use the provided code generation tools
4. Follow the existing code style
5. Document all public APIs

## 📄 License

This project is private and proprietary.

## 👥 Team

Developed for construction management with modern Flutter best practices.

## 🆘 Support

For issues or questions, please contact the development team.

---

**Built with ❤️ using Flutter and Clean Architecture**
