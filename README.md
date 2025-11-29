# 📸 AI Photo Categorizer App (Flutter + Python Flask)

An AI-based photo categorization system that classifies images based on scene type and detects the number of faces in each photo. The project consists of:

- **Flutter Mobile App** → lets users pick multiple images, send them to backend, and automatically saves categorized images in device storage.
- **Python Flask Backend** → runs a Places365-based ResNet18 scene classifier + face detection (`face_recognition` library).
- **Automatic Sorting** → saves images into categorized folders in `/storage/emulated/0/Pictures/PhotoCategorizer/<Category>/`.

---

## 🚀 Features

### 📱 Flutter App
- Pick multiple images from gallery
- Sends images to Flask backend
- Displays predicted category for each image
- Saves images into phone folders by category automatically
- Clean Material UI
- Supports Android 10–14
- Handles permissions (READ/WRITE storage)

### 🧠 Flask Backend
- Scene classification using **ResNet18 Places365**
- Face detection using `face_recognition`
- APIs:
  - `/ping` → server status
  - `/upload_multiple` → upload & classify multiple images
- Returns JSON with:
  - scene category
  - number of faces
  - processed filename

---

## 📂 Project Structure

📁 AI-Photo-Categorizer
├── flutter_app/
│ ├── lib/main.dart
│ ├── assets/
│ ├── android/
│ └── pubspec.yaml
├── backend/
│ ├── app.py
│ ├── utils/
│ ├── models/
│ └── requirements.txt
└── README.md

yaml
Copy code

---

## 🧠 Tech Stack

### Frontend (Mobile App)
- Flutter (Dart)
- Material UI
- image_picker
- http
- permission_handler

### Backend (AI Server)
- Python Flask
- PyTorch
- TorchVision
- face_recognition
- PIL
- NumPy

---

## 📡 API Endpoints

### 🔹 Check Server Status
```http
GET /ping
🔹 Upload Multiple Images
http
Copy code
POST /upload_multiple
form-data: files[] = <multiple images>
Sample JSON Response:
json
Copy code
[
  {
    "image": "sample.jpg",
    "scene": "kitchen",
    "faces": 2
  }
]
📁 Categorized Folder Structure
Images are saved by category here:

swift
Copy code
/storage/emulated/0/Pictures/PhotoCategorizer/<Category>/
Example:

Copy code
Kitchen/
Outdoor/
LivingRoom/
Garden/
🛠️ Run Backend
1️⃣ Install dependencies
bash
Copy code
pip install -r requirements.txt
2️⃣ Start Flask server
bash
Copy code
python app.py
Backend runs at:

cpp
Copy code
http://<your-ip>:5000
📱 Run Flutter App
1️⃣ Install packages
bash
Copy code
flutter pub get
2️⃣ Connect your phone
Enable USB debugging.

3️⃣ Run the app
bash
Copy code
flutter run
4️⃣ Enter Flask IP inside app
Example:

Copy code
10.50.24.70
Tap Connect → Select images → Categorization starts.

🔒 Android Permissions Used
INTERNET

ACCESS_NETWORK_STATE

READ_EXTERNAL_STORAGE

WRITE_EXTERNAL_STORAGE

MANAGE_EXTERNAL_STORAGE (Android 11+)

READ_MEDIA_IMAGES (Android 13+)

⭐ Future Scope
Full offline version using TFLite

More accurate face detection

Add custom user categories

Gallery grid view UI

Cloud backup and sync option

👨‍💻 Author
Manideep Nunna
Department of CSE (AI & ML), VIT-AP University

📜 License
This project is licensed under the MIT License.
See LICENSE file for details.

⭐ Support
If you like this project, please give a ⭐ star on GitHub!






