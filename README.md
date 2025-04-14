# MediFlow - Your Personal Health Companion

MediFlow is a comprehensive healthcare management application built with Flutter and Firebase. It provides users with a seamless way to manage their health records, consult with doctors, and access medical assistance through an AI-powered chatbot.

## Features

### 1. Authentication
- Secure email/password authentication using Firebase Auth
- User registration and login functionality
- Session management and persistence

### 2. Health Profile Management
- Personal medical information storage
- Physical measurements tracking
- Medical history documentation
- Blood group and allergy information
- BMI calculation and tracking

### 3. AI-Powered Medical Assistant
- Interactive chatbot for medical queries
- Pre-visit questionnaire
- Symptom analysis
- Medical advice and information
- Chat history tracking

### 4. Doctor Consultation
- Video consultation scheduling
- Phone consultation booking
- Chat consultation with doctors
- Appointment management
- Consultation history

### 5. Medical Reports
- Chat history documentation
- Consultation summaries
- Medical record storage
- Report sharing capabilities

### 6. Notifications
- Appointment reminders
- Consultation updates
- Medical report availability
- Health check reminders

### 7. Settings and Preferences
- Dark mode support
- Notification preferences
- Language selection
- Account management

## Technical Stack

- **Frontend**: Flutter
- **Backend**: Firebase
  - Authentication: Firebase Auth
  - Database: Cloud Firestore
  - Storage: Firebase Storage
- **AI Integration**: Google Gemini API
- **State Management**: Provider
- **UI Components**: Material Design
- **Fonts**: Google Fonts (Poppins)

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── services/
│   ├── firestore_service.dart # Firebase database operations
│   └── medical_history_service.dart # Medical history management
├── screens/
│   ├── login.dart            # Login screen
│   ├── register.dart         # Registration screen
│   ├── home_dashboard.dart   # Main dashboard
│   ├── medical_summary.dart  # Health profile
│   ├── chatbot.dart          # AI medical assistant
│   ├── report_history.dart   # Medical reports
│   ├── contact_doctor.dart   # Doctor consultation
│   ├── video_consultation.dart # Video call scheduling
│   ├── chat_consultation.dart # Doctor chat
│   └── settings_screen.dart  # User preferences
├── models/
│   └── patient_profile.dart  # Patient data model
└── widgets/                  # Reusable UI components
```

## Setup Instructions

1. **Prerequisites**
   - Flutter SDK (latest version)
   - Dart SDK (latest version)
   - Android Studio / VS Code
   - Firebase account

2. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Set up Firestore database
   - Add Firebase configuration files
   - Enable Cloud Storage

3. **Installation**
   ```bash
   # Clone the repository
   git clone https://github.com/yourusername/medi_flow.git
   
   # Navigate to project directory
   cd medi_flow
   
   # Install dependencies
   flutter pub get
   
   # Run the application
   flutter run
   ```

4. **Environment Configuration**
   - Add your Firebase configuration in `lib/firebase_options.dart`
   - Set up Google Gemini API key for AI features
   - Configure notification settings

## Usage Guide

1. **Registration and Login**
   - Create a new account with email and password
   - Complete the initial health profile setup
   - Access the dashboard after successful login

2. **Health Profile**
   - Enter personal information
   - Add medical history
   - Update physical measurements
   - Track health metrics

3. **Medical Assistant**
   - Access the AI chatbot
   - Ask medical questions
   - Get symptom analysis
   - View chat history

4. **Doctor Consultation**
   - Schedule video/phone consultations
   - Chat with doctors
   - View appointment history
   - Access consultation reports

5. **Reports and History**
   - View medical reports
   - Access consultation summaries
   - Track health progress
   - Share reports with doctors

## Security Features

- End-to-end encryption for sensitive data
- Secure authentication with Firebase
- Role-based access control
- Data privacy compliance
- Secure API communication

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

#   m e d i _ f l o w  
 