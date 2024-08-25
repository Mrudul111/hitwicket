Project Overview

This repository contains the code for a chess game developed for Hit Wicket Company. The game adheres to the Model-View-Controller (MVC) architectural pattern for better organization and maintainability.

Technologies Used

Frontend: Dart (Flutter)
Backend: JavaScript (Node.js)
Project Structure

chess-game
├── lib
│   ├── main.dart
│   ├── views
│   │   └── game_page.dart
│   ├── controllers
│   │   └── theme_provider.dart
│   │   └── game_provider.dart
├── server
│   └── server.js
└── README.md

MVC Implementation

Model: Represents the data and logic of the game (located in game_provider.dart).
Chessboard state, piece movements, game rules, etc.
View: Handles the user interface (located in game_page.dart).
Renders the chessboard, pieces, and other visual elements.
Controller: Mediates between the model and view (located in theme_provider.dart).
Manages the application's theme and other global state.
Features

Multiplayer: Allows players to connect and play against each other in real-time.
AI Opponent: Provides an AI opponent for single-player games.
Game History: Records previous moves and allows players to review them.
User Profiles: Stores player information, game statistics, and rankings.
Chat Functionality: Enables players to communicate with each other during games.
Getting Started

Clone the repository:
Bash
git clone https://github.com/your-username/chess-game.git
Use code with caution.
Install dependencies:
Frontend: Navigate to the lib directory and run flutter pub get.
Backend: Navigate to the server directory and run npm install.
Run the development server:
Frontend: Run flutter run in the lib directory.
Backend: Run node server.js in the server directory.
Contributing

 Contributions are welcome! Please follow these guidelines:

Fork the repository.
Create a new branch for your feature or bug fix.   
Make your changes and commit them.
Push your changes to your fork.
Create a pull request to the main branch of the original repository.   
