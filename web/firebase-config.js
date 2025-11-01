// Firebase configuration for TaskPet - Gamified Todo App
const firebaseConfig = {
  apiKey: "AIzaSyBW9x1100FT6AN4pYwNP_7Kov7-IMrZBJI",
  authDomain: "taskpet---gamified-todo-df1b8.firebaseapp.com",
  projectId: "taskpet---gamified-todo-df1b8",
  storageBucket: "taskpet---gamified-todo-df1b8.firebasestorage.app",
  messagingSenderId: "278853249268",
  appId: "1:278853249268:web:39743c2b30bc70026916a1",
  measurementId: "G-DXBK8HHH5J"
};

// For Flutter Web - minimal configuration
console.log('Firebase config loaded:', firebaseConfig);
window.firebaseConfig = firebaseConfig;