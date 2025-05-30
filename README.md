# MediFlow - Your Personal Health Companion
MediFlow is a comprehensive healthcare application that provides users with a seamless experience for managing their health information, consulting with doctors, and accessing medical assistance.
## Features
### 1. User Authentication
- Secure login and registration system
- Firebase Authentication integration
- User profile management
### 2. Health Profile Management
- Personal information storage
- Medical history tracking
- Physical measurements and vitals
- Blood group and BMI tracking
### 3. Doctor Consultation
- Video consultation scheduling
- Phone consultation requests
- Real-time chat with doctors
- Appointment management
### 4. AI-Powered Medical Assistant
- Pre-visit questionnaire
- Symptom analysis
- Medical advice and information
- Chat-based interaction
### 5. Medical Reports
- Chat history storage
- Consultation summaries
- Report sharing capabilities
### 6. Notifications
- Appointment reminders
- Consultation updates
- System notifications
## Technical Implementation
### Data Storage
- **Firestore Database**: Used for storing all user data, including:
  - User profiles
  - Medical history
  - Consultation records
  - Chat histories
  - Appointment schedules
### Authentication
- Firebase Authentication for secure user management
- Email/password authentication
- User session management
### Real-time Features
- Live chat with doctors
- Real-time appointment updates
- Instant notifications
### AI Integration
- Gemini AI integration for medical assistance
- Natural language processing for chat interactions
- Pre-visit questionnaire automation
## Getting Started
### Prerequisites
- Flutter SDK
- Firebase project
- Google Cloud account
### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your Firebase configuration files
   - Enable Firestore database
   - Set up Firebase Authentication
4. Run the application:
   ```bash
   flutter run
   ```
## Project Structure
```
lib/
├── main.dart
├── login.dart
├── register.dart
├── home_dashboard.dart
├── medical_summary.dart
├── chatbot.dart
├── report_history.dart
├── settings_screen.dart
├── contact_doctor.dart
├── video_consultation.dart
├── chat_consultation.dart
└── models/
    └── patient_profile.dart
```
## Dependencies
- `firebase_core`: Firebase core functionality
- `firebase_auth`: User authentication
- `cloud_firestore`: Database operations
- `flutter_gemini`: AI integration
- `google_fonts`: Typography
- `table_calendar`: Calendar widget
- `intl`: Date formatting
## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
