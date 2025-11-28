# AI-based Offline Photo Categorization App

This project is an **offline image categorization system** built using:

- **Flutter** – Frontend mobile application  
- **Flask** – Backend REST API for offline image classification  
- **Lightweight machine learning model** (MobileNet/EfficientNet/custom)

The app allows users to upload photos, which are then categorized into albums such as **People, Nature, Documents, Food, Vehicles, Others** — all without requiring an internet connection.

---

## 📌 Project Structure

```markdown
AI-based Offline Photo Categorization App/
│
├── flutter_app/              # Flutter mobile application
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── (other Flutter files)
│
├── flask_backend/            # Flask backend + ML model
│   ├── app.py
│   ├── requirements.txt
│   └── model/
│
├── README.md                 # Project documentation (you are here)
├── LICENSE                   # MIT License
└── .gitignore                # Git ignore rules
```

---

## 🚀 Features

- Fully **offline** functioning AI-based image categorization  
- Clean Flutter UI with easy photo selection  
- Batch image uploading  
- Categorized albums for better organization  
- Fast inference using lightweight ML model  
- REST API communication between Flutter and Flask  
- Works on Android, iOS, Windows, Linux, macOS  

---

## ⚙️ Backend Setup — Flask API

1. Navigate to backend folder:

```bash
cd flask_backend
```

2. Create Python virtual environment:

```bash
python -m venv venv
```

3. Activate venv:

**Windows:**
```bash
venv\Scripts\activate
```

**Mac/Linux:**
```bash
source venv/bin/activate
```

4. Install requirements:

```bash
pip install -r requirements.txt
```

5. Run backend:

```bash
python app.py
```

Backend will run on:

```
http://127.0.0.1:5000
```

---

## 📱 Frontend Setup — Flutter App

1. Navigate to Flutter project:

```bash
cd flutter_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

---

## 🌐 Backend URL for Flutter

Use this URL inside Flutter code when calling `/predict`:

- **Android Emulator:**  
  ```
  http://10.0.2.2:5000
  ```

- **Physical Device (same Wi-Fi):**  
  ```
  http://<your-laptop-IP>:5000
  ```

- **Desktop Mode:**  
  ```
  http://127.0.0.1:5000
  ```

---

## 🧠 How the App Works (Architecture)

1. User selects photos in Flutter  
2. Flutter sends photos to backend (Flask) through `/predict` API  
3. Flask loads ML model and performs classification  
4. Backend sends predicted category back to Flutter  
5. Flutter groups photos into category-based albums  
6. User views images organized by category  

(You may add an architecture diagram as `ARCHITECTURE.png`.)

---

## 📄 License

This project is licensed under the **MIT License**.  
See the `LICENSE` file for more details.

---

## 👨‍💻 Developer

**Mani Deep Nunna**  
B.Tech CSE (AI & ML), VIT-AP University

