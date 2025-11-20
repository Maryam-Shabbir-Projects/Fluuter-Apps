#link for screnrecording
https://drive.google.com/file/d/1sGYKrUNEogYb4ybC-BqbWM81Bgnde-vU/view?pli=1

#link for apk

https://drive.google.com/file/d/1dpdd3g3YMqQ8dfPbZUNpDg4pO5SXIle4/view?usp=drive_link

Task Management App – Documentation

 Overview
 
 The Task Management App is a Flutter-based mobile application designed to help users add,
 update, delete, and track tasks efficiently. It includes reminder notifications and sound alerts for due
 or expired tasks, enhancing productivity and time management.
 
 Features
 
 • Add, update, and delete tasks
 • Set due date & time
 • Real-time notifications for task deadlines
 • Sound alerts for expired tasks
 • Welcome screen for better UX
 • Responsive UI with clean design
 • Local data storage
 
 App Architecture
 
 The app follows a structured folder-based architecture:
 • **UI Layer** – Screens & widgets
 • **Logic Layer** – Providers / State management
 • **Services** – Notification service, audio player service
 • **Models** – Task model with fields (title, description, dueDate, etc.)
 
 Folder Structure
 
 lib/
 main.dart
 models/
 task_model.dart
 screens/
 welcome_screen.dart
 home_screen.dart
 add_task_screen.dart
 update_task_screen.dart
 services/
 notification_service.dart
 sound_service.dart
 widgets/
 custom_widgets.dart
 utils/
 theme.dart
 
Technologies Used

 • Flutter
 • Dart
 • audioplayers (for sound alerts)
 • flutter_local_notifications (for scheduled notifications)
 
 Installation
 
 1. Clone the repository
 2. Run: `flutter pub get`
 3. Connect a device or emulator
 4. Run the app using: `flutter run`

 How Notifications Work
 
 • When a task is created/updated, the app schedules a notification
 • When the task time expires, the notification appears
 • Sound is played using the audioplayers package
 How to Add a Welcome Screen
 The welcome screen is placed as the initial route. It displays branding, overview text, and navigates
 to the home screen. It improves user experience and onboarding.
 
 Contributing
 
 1. Fork the project
 2. Create a new feature branch
 3. Commit your changes
 4. Submit a pull request
    
 License
 
 This project is open-source and free to modify.



