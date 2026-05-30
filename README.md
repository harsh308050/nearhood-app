# Nearhood

**Your Neighborhood. Verified.**  
*A Verified Hyperlocal Community Network for India*

---

## 📖 Overview

Nearhood is a verified hyperlocal social network built exclusively for India. It connects people who live in the same locality — same streets, same area, real neighbors — on a single trusted, real-name platform. 

Inspired by platforms like Nextdoor but fundamentally redesigned for the Indian reality (dense localities, apartment complexes, strong community cultures, and a mobile-first population), Nearhood brings structured, organized, and verified communication to your neighborhood.

*"Think of Nearhood as WhatsApp groups done right — organized, verified, permanent, and actually useful."*

---

## 🎯 Core Philosophy

Nearhood is built on three non-negotiable principles:
1. **Everything is local** — Every post, every user, every interaction is anchored to a specific real-world locality. 
2. **Everyone is real** — Every account is backed by a verified phone number and a real name. No anonymity.
3. **Everything is relevant** — The feed only shows content that is genuinely useful to people who live in that exact area.

---

## ✨ Key Features

- **Neighborhood Feed**: A real-time stream of posts categorized into General, Questions, Recommendations, Events, and more.
- **Safety Alerts**: Urgent, high-priority push notifications sent to all nearby residents for theft, suspicious activity, fires, or road closures.
- **Local Marketplace**: A hyper-proximity platform to buy, sell, or give away items within walking or short driving distance.
- **Local Business Directory**: A neighbor-driven directory of local service providers (plumbers, electricians, tutors) reviewed and rated by actual residents.
- **Direct Messaging**: Private communication between verified neighbors with built-in listing card sharing.
- **Area Leads**: Trusted, long-term residents who act as community stewards to pin official announcements and moderate content.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart) for Android & iOS cross-platform development
- **State Management**: [Riverpod](https://riverpod.dev/) for predictable, scalable feed and real-time state management
- **Authentication**: Firebase Auth (Phone OTP, Google, Email)
- **Database**: Firebase Firestore for real-time syncing of feeds, messaging, and notifications
- **Storage**: Firebase Storage / Cloudflare R2
- **Maps & Location**: Google Maps SDK + Google Places API for locality boundary polygons
- **Identity Verification**: Integrated with DigiLocker API (for optional Aadhaar name confirmation)

---

## 🚀 Setup & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Dart SDK](https://dart.dev/get-dart)
- IDE (VS Code, Android Studio, or IntelliJ)
- Firebase Project configured for both iOS and Android

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/nearhood.git
   cd nearhood
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Place your `google-services.json` in `android/app/`
   - Place your `GoogleService-Info.plist` in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔒 Verification & Privacy System

Nearhood uses a strict **Two-Layer Verification Architecture**:
1. **Identity (Who are you?)**: Mandatory Phone OTP + optional Aadhaar name confirmation via DigiLocker.
2. **Location (Where do you live?)**: GPS-detected locality + user confirmation.

**Privacy Principles:**
- Exact addresses are **never** displayed to other users (only the locality name is visible).
- Aadhaar numbers and biometric data are **never** collected or stored.
- Direct messages are strictly private and inaccessible to Area Leads or admins.
- Full compliance with India's DPDP Act (2023).

---

## 📜 Community Rules

Every Nearhood user must agree to these four pillars of the community before joining:
1. **Be Helpful** — Share useful, accurate information.
2. **Lead with Respect** — Treat every neighbor with dignity.
3. **Do Not Harm** — Never post content that threatens or endangers others.
4. **All Are Welcome** — Nearhood is for everyone; no discrimination is tolerated.

---

## 🔮 Vision
Nearhood's 5-year vision is to become the **default layer of neighborhood infrastructure for urban India** — the place every Indian resident checks to know what is happening on their street, find a local service, or stay safe in their area.
