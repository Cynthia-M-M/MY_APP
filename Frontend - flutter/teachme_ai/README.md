# 🚀 TeachMe AI

**The Voice-First Vocational Operating System for the Next Billion Users.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Status](https://img.shields.io/badge/Status-MVP_Live-green?style=for-the-badge)

TeachMe AI is a mobile platform designed for the **400 million illiterate adults in Africa**. It removes the barrier of reading and typing, allowing users to learn trade skills (Plumbing, Farming, Hairdressing) using **100% Voice and Visual interactions** in their local dialect (Swahili/Sheng).

---

## ✨ Key Features

* **🗣️ Zero-UI Interface:** No keyboards, no search bars. Just a giant glowing button that listens.
* **🌍 Vernacular First:** Auto-greets and responds in Swahili (`sw-KE`).
* **🧠 Smart Matching Engine:** Recognizes intent (e.g., "Maji", "Nataka maji", "Bomba") and maps it to the correct video.
* **💰 Micro-Payment Integration:** Features a 15-second "Free Preview" followed by an M-Pesa paywall simulation.
* **📼 Curated Content:** Database of 60+ keywords mapped to real, verified vocational YouTube tutorials.

---

## 🛠️ Tech Stack

### **Frontend (Mobile)**
* **Framework:** Flutter (Dart)
* **Voice:** `speech_to_text` (Offline/Online hybrid)
* **Feedback:** `flutter_tts` (Swahili Text-to-Speech)
* **Visuals:** `avatar_glow` (Interactive listening states)
* **Video:** `Youtubeer_flutter`

### **Backend (Server)**
* **Framework:** Python Flask (Chosen for Python 3.13 compatibility & speed)
* **Architecture:** REST API
* **Database:** In-memory dictionary (Scalable to SQL)
* **Logging:** Comprehensive emoji-based logging system

---

## 🚀 Quick Start Guide

### Prerequisites
* Flutter SDK installed
* Python 3.10+ installed

### 1. Setup the Backend (Python)
This handles the logic and video mapping.

```bash
cd backend
# Install lightweight dependencies (No Rust compiler needed!)
pip install flask flask-cors

# Run the server
python main.py
Output: 🚀 TeachMe AI Backend Starting... Server: http://0.0.0.0:80002. Setup the Frontend (Flutter)This runs the mobile app.Bashcd frontend
# Get dependencies
flutter pub get

# Run on Emulator or Device
flutter run
📱 How to Use (Demo Flow)
Open the App: It greets you: "Karibu. Gusa kioo na uniambie unataka kujifunza nini."

Tap the Green Circle: It turns RED and listens.

Speak a Command:

Say "Maji" → Plays a Plumbing tutorial.

Say "Nywele" → Plays a Hair Braiding class.

Say "Shamba" → Plays a Farming guide.

The Paywall: After 15 seconds, the video pauses. Click the "Lipa Na M-Pesa" button to unlock and continue.

🔌 API Endpoints
Method	Endpoint	Description
POST	/process-voice	Sends spoken text, returns video ID & TTS reply.
GET	/videos	Lists all 60+ mapped videos.
GET	/stats	Shows usage statistics.
POST	/test	Debug endpoint to test matching logic.

Export to Sheets

🔮 Roadmap
[x] Phase 1: Voice-to-Video MVP (Completed)

[ ] Phase 2: Real M-Pesa STK Push Integration

[ ] Phase 3: Offline Mode (Downloadable Content)

[ ] Phase 4: AI Certification (Voice Quiz to verify skills)

👩‍💻 Author
Cynthia Moraa Software Engineer | Flutter & Python Expert PLP Alumna

Built with ❤️ in Kenya for the Jua Kali Sector.