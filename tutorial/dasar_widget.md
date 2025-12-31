# 📱 My Apps (Flutter)

A simple Flutter application to learn basic UI using **Material Design**.

This app displays:
- Blue AppBar
- White AppBar title
- "Hello World" text centered on the screen

---

## 🚀 Features
- MaterialApp setup
- Scaffold layout
- Custom AppBar color
- Custom title text style
- Centered text widget

---

## 🛠️ Built With
- Flutter
- Dart
- Material Design

---

## 📂 Project Structure
```
lib/
 └── main.dart
```

---

## ▶️ How to Run

1. Make sure Flutter is installed:
   ```bash
   flutter doctor
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/my-apps-flutter.git
   ```

3. Navigate to the project folder:
   ```bash
   cd my-apps-flutter
   ```

4. Run the app:
   ```bash
   flutter run
   ```

---

## 🧠 Code Explanation

### Import Material Library
```dart
import 'package:flutter/material.dart';
```

### Main Function
```dart
void main() {
  runApp(const MyApps());
}
```

### Root Widget
```dart
class MyApps extends StatelessWidget {
```

### MaterialApp
```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
)
```

### Scaffold & AppBar
```dart
Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.blue,
    title: Text(
      "My Apps",
      style: TextStyle(color: Colors.white),
    ),
  ),
)
```

### Body Content
```dart
Center(
  child: Text("Hello World"),
)
```

---

## 🧩 Full Source Code

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApps());
}

class MyApps extends StatelessWidget {
  const MyApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'My Apps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Hello World',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 👨‍💻 Author
Rizki Utama

---

## 📄 License
MIT License