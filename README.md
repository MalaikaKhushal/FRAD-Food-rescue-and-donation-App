#  FRAD – Food Rescue and Donation App

> **FRAD (Food Rescue and Donation App)** is a Flutter and Firebase based mobile application developed to reduce food waste by connecting food providers with customers who can reserve surplus food at discounted prices or receive donated food.

---

##  Project Overview

Every day, restaurants, bakeries, hostel messes, and event caterers have surplus food that often goes to waste. FRAD provides a platform where food providers can upload available surplus food, and customers can discover, reserve, and collect it before it expires.

The project aims to:

* Reduce food waste
* Promote food donation
* Help providers recover part of their costs
* Offer affordable food to customers
* Encourage sustainable food management

---

#  Features

##  Customer

* User Registration & Login
* Browse Available Food
* Search Food
* View Food Details
* Reserve Food
* View My Orders
* Receive Real-Time Notifications
* Saved/Favorite Foods
* Nearby Foods
* Customer Profile

---

##  Provider

Supported Providers:

* Restaurant
* Bakery
* Hostel Mess
* Event Caterer

Provider Features:

* Login & Registration
* Add Food Listings
* Edit Food Listings
* Delete Food Listings
* View My Listings
* Manage Reservations
* Accept Orders
* Mark Food Ready
* Complete Orders
* Cancel Reservations
* Receive Reservation Notifications

---

#  Technologies Used

### Frontend

* Flutter
* Dart
* Material UI

### Backend

* Firebase Authentication
* Cloud Firestore
* Firebase Core

### State Management

* StatefulWidget
* StreamBuilder
* Future

---

#  Project Structure

```text
lib/
│
├── models/
│   ├── food_model.dart
│   ├── reservation_model.dart
│   └── notification_model.dart
│
├── services/
│   └── firestore_service.dart
│
├── screens/
│   ├── splashscreen.dart
│   ├── landingpage.dart
│   ├── loginscreen.dart
│   ├── signupscreen.dart
│   ├── customerdashboard.dart
│   ├── providerdashboard.dart
│   ├── add_food_screen.dart
│   ├── my_listings_screen.dart
│   ├── food_detail_screen.dart
│   ├── orders_screen.dart
│   ├── reservations_screen.dart
│   ├── notification_screen.dart
│   ├── nearby_foods_screen.dart
│   └── profile_screen.dart
│
├── firebase_options.dart
└── main.dart
```

---

# Firebase Collections

## users

Stores user information.

```text
uid
fullName
email
phone
role
```

---

## food_listings

Stores all available food.

```text
foodId
providerId
foodName
description
category
quantity
originalPrice
discountPrice
donation
pickupDate
pickupTime
expiryTime
location
imageUrl
status
createdAt
```

---

## reservations

Stores customer reservations.

```text
reservationId
customerId
customerName
providerId
providerName
foodId
foodName
status
createdAt
```

---

## notifications

Stores notification messages.

```text
title
message
targetUserId
targetRole
createdAt
readBy
```

---

#  Application Flow

```text
Splash Screen
        │
        ▼
Landing Page
        │
        ▼
Login / Signup
        │
        ▼
Role Check
 ┌───────────────┐
 │               │
 ▼               ▼
Customer     Provider
Dashboard    Dashboard
 │               │
 ▼               ▼
Food List     Add Food
 │               │
 ▼               ▼
Food Detail  My Listings
 │               │
 ▼               ▼
Reserve      Reservations
 │               │
 ▼               ▼
Orders      Update Status
 │               │
 └──────► Notifications ◄──────┘
```

---

#  Main Modules

* Authentication
* Role-Based Login
* Food Management
* Reservation Management
* Orders
* Notifications
* Nearby Foods
* User Profiles

---

#  Future Enhancements

* Google Maps Integration
* Live GPS Tracking
* Payment Gateway
* QR Code Pickup Verification
* Admin Dashboard
* Food Recommendation System
* Rating & Review System
* Chat Between Customer and Provider

---

#  Team Members

* Momna Tariq
* Malaika Khushal

---

#  Academic Project

This project was developed as a Semester Project for the **Mobile Application Development** course using **Flutter** and **Firebase**.

---

# Screens Included

* Splash Screen
* Landing Page
* Login
* Signup
* Customer Dashboard
* Provider Dashboard
* Add Food
* My Listings
* Food Details
* Orders
* Reservations
* Notifications
* Nearby Foods
* Profile

---

#  Getting Started

Clone the repository:

```bash
git clone https://github.com/<your-repository-link>.git
```

Install packages:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# License

This project is developed for educational purposes only.
