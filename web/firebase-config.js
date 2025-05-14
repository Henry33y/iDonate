// Import the functions you need from the SDKs you need
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
import { getMessaging } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging.js";

// Your web app's Firebase configuration
const firebaseConfig = {
  // Add your Firebase configuration here
  apiKey: "AIzaSyCnfBd20E5_D-RPTbDE2G0LKDOVhnBRd8M",
  authDomain: "idonate-c030e.firebaseapp.com",
  projectId: "idonate-c030e",
  storageBucket: "idonate-c030e.firebasestorage.app",
  messagingSenderId: "655086831488",
  appId: "1:655086831488:web:9cf7266977cc7e1ca9e365"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const messaging = getMessaging(app);

// Make Firebase services available globally
window.firebase = {
  app,
  auth,
  db,
  messaging
}; 