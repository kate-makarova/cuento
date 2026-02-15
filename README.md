# Cuento

Cuento is a modern roleplaying forum platform that combines the classic feel of traditional forum software with contemporary web technologies. It features a high-performance backend written in Go and a responsive, single-page application frontend built with Angular.

## Project Structure

This repository contains the two main components of the Cuento platform as submodules:

- **[Backend](backend/README.md)**: A robust API server built with Go (Golang) and the Gin framework. It handles data persistence, authentication, real-time notifications via WebSockets, and the core business logic for forums, topics, and dynamic entity management.
- **[Frontend](frontend/README.md)**: A modern web interface built with Angular (v17+). It provides a rich user experience for browsing forums, managing characters, and participating in roleplay episodes, utilizing reactive state management with Angular Signals.

## Features

- **Forum System**: Comprehensive support for categories, subforums, topics, and posts with BBCode parsing.
- **Roleplay Focused**: Specialized features for roleplaying communities, including:
  - **Character Sheets**: Dynamic character profiles with custom fields (text, images, etc.).
  - **Faction Management**: Hierarchical faction trees.
  - **Episode Tracking**: Tools for managing roleplay episodes.
- **Dynamic Entity System**: Flexible custom field definitions for entities like characters and episodes, backed by an optimized hybrid storage system (EAV + flattened tables).
- **Real-Time Updates**: WebSocket integration for live notifications and updates.
- **Modern Architecture**:
  - **Backend**: Go, Gin, MySQL/MariaDB, Gorilla WebSocket.
  - **Frontend**: Angular, TypeScript, Signals for state management.

## Getting Started

To set up the full Cuento project, you will need to initialize the submodules and follow the setup instructions for both the backend and frontend.

### Prerequisites

- **Git**
- **Go 1.18+** (for Backend)
- **Node.js v18+ & npm** (for Frontend)
- **MySQL or MariaDB** database

### Installation

1. **Clone the repository with submodules:**
   ```bash
   git clone --recurse-submodules https://github.com/kate-makarova/cuento.git
   cd cuento
   ```

   If you have already cloned the repository without submodules, run:
   ```bash
   git submodule update --init --recursive
   ```

2. **Setup Backend:**
   Navigate to the `backend` directory and follow the instructions in the [Backend README](backend/README.md).
   ```bash
   cd backend
   # Follow backend setup steps...
   ```

3. **Setup Frontend:**
   Navigate to the `frontend` directory and follow the instructions in the [Frontend README](frontend/README.md).
   ```bash
   cd ../frontend
   # Follow frontend setup steps...
   ```

## License

This project is licensed under the Apache 2.0 License. See the `LICENSE` file in each submodule for specific details.
