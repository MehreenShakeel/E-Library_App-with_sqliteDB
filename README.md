# E-Library Management System  
**A Modern Cross-Platform Digital Library App**  

[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-blue.svg)](https://flutter.dev)  
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-blue.svg)](https://dart.dev)  
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Linux-brightgreen)](#)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful, fast, and fully functional **E-Library Management System** built with **Flutter**.  
Runs perfectly on **Android, Web (Chrome), and Linux Desktop** using a **single codebase**.

---

### Key Features

- Add, search, rate (1–5 stars), and delete books  
- Add, search, and delete library members  
- Powerful full-text search for books and members  
- Smart **AI Chatbot** powered by Google Gemini  
- 100% offline (except chatbot)  
- **Persistent local storage** on every platform:  
  → Android & Linux: Real **SQLite** database  
  → Web: Browser **IndexedDB** (via SharedPreferences)  
- Modern Material 3 design with orange theme  
- Clean, fully English user interface  
- Data survives app close and device restart  

---

### Technologies Used

| Technology               | Purpose                                  |
|--------------------------|------------------------------------------|
| Flutter                  | Cross-platform UI framework             |
| Dart                     | Programming language                     |
| SQLite + sqflite         | Local database (mobile & desktop)        |
| sqflite_common_ffi       | SQLite support on Linux                  |
| SharedPreferences        | Persistent storage on Web                |
| Google Generative AI     | AI Chatbot (Gemini)                      |
| flutter_rating_bar       | Interactive star rating                  |

---

### How to Run the Project

```bash
# Clone the repo
git clone https://github.com/yourusername/elmouaddibe_examen.git
cd elmouaddibe_examen

# Install dependencies
flutter pub get