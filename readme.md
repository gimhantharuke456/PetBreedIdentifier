# Pet Breed Identifier App

## Project Overview

The **Pet Breed Identifier App** is a user-friendly platform where pet enthusiasts can:

- **Create, Edit, Delete, and View** pet-related posts in a social media-style **Feed Section** (similar to Instagram).
- Identify **dog breeds** using a Machine Learning (ML) model built with **MLCore** and trained using **TensorFlow**.

This app leverages Firebase services to manage user authentication, data storage, and media uploads.

---

## Features

1. **Feed Section**:
   - Users can create posts about their pets with images and descriptions.
   - Edit or delete existing posts.
   - View a feed of all posts shared by users.
2. **Dog Breed Identifier**:

   - Upload a picture of a dog to identify its breed instantly.
   - Model trained using TensorFlow with optimized accuracy and real-time results.

3. **Firebase Integration**:
   - **Firebase Authentication**: Secure user login and registration.
   - **Firebase Cloud Firestore**: Store and retrieve user-generated posts and metadata.
   - **Firebase Storage**: Manage image uploads efficiently.

---

## Technologies Used

- **Frontend**: iOS (Swift/SwiftUI)
- **Backend**: Firebase services for cloud-based operations
- **Machine Learning**:
  - Training: TensorFlow
  - Model Deployment: MLCore
- **Languages**: Python (for model training), Swift (app development)

---

## Screenshots

### App Interface Previews

| Feature               | Screenshot                                                                                                                                                                                                                                           |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Feed Section          | ![Feed Section](https://firebasestorage.googleapis.com/v0/b/kavinda-f44d7.appspot.com/o/petbreed%2FSimulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-11-28%20at%2021.33.00.png?alt=media&token=df371d47-0027-4620-99c1-8dafb3dd4535)         |
| Creating a Post       | ![Create Post](https://firebasestorage.googleapis.com/v0/b/kavinda-f44d7.appspot.com/o/petbreed%2FSimulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-11-28%20at%2021.33.04.png?alt=media&token=4930628b-46c5-44cb-a216-21e7e1add86a)          |
| Identifying Dog Breed | ![Dog Breed Identifier](https://firebasestorage.googleapis.com/v0/b/kavinda-f44d7.appspot.com/o/petbreed%2FSimulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-11-28%20at%2021.33.31.png?alt=media&token=a9cd3d7d-fc28-4e75-8a62-a0c31495fd0a) |
| Post View             | ![Post View](https://firebasestorage.googleapis.com/v0/b/kavinda-f44d7.appspot.com/o/petbreed%2FSimulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-11-28%20at%2021.34.11.png?alt=media&token=76e723af-eb10-4690-b5a8-44f3c2506e89)            |

---

## How It Works

1. **User Authentication**:
   - Users sign up or log in via Firebase Authentication.
2. **Posting and Editing**:
   - Posts can be created, edited, or deleted via the feed interface.
   - Images and text descriptions are saved in Firebase Cloud Firestore and Storage.
3. **Dog Breed Detection**:
   - Users upload a dog image.
   - The app uses the MLCore-integrated model to predict the dog's breed in real-time.

---

## Installation & Setup

1. Clone the repository to your local machine.
2. Install the required libraries and dependencies.
3. Configure your Firebase project with:
   - Authentication
   - Firestore
   - Storage
4. Import the trained TensorFlow model into MLCore for deployment.
5. Run the app in Xcode or your preferred iOS simulator.

---

## Acknowledgments

- **Kaggle Dataset**: Used to train the dog breed detection model.
- **TensorFlow**: Framework used for ML model training.
- **Firebase**: Used for backend services.
- **ChatGPT**: Provided guidance and code improvements.

---

## Developer Information

- **Name**: [Your Name Here]
- **IT Number**: [Your IT Number Here]
