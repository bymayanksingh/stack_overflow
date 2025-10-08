# Stack Overflow Clone - React Frontend

A modern React frontend for the Stack Overflow clone application, built with TypeScript and Tailwind CSS.

## Features

- **Search Interface**: Clean, Stack Overflow-inspired search interface
- **Question Display**: Beautiful question cards with metadata and answer previews
- **AI Reranking**: Toggle between original and AI-reranked answers
- **User Management**: Create and manage users
- **Recent Searches**: View and reuse recent search queries

## Tech Stack

- **React 18** with TypeScript
- **Tailwind CSS** for styling
- **React Router** for navigation
- **Axios** for API communication
- **Lucide React** for icons
- **React Markdown** for content rendering

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Backend API running on port 4000

### Installation

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Set environment variables**:
   Create a `.env` file in the root directory:
   ```
   REACT_APP_API_URL=http://localhost:4000/api
   ```

3. **Start the development server**:
   ```bash
   npm start
   ```

The application will be available at `http://localhost:3000`.

## Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run tests
- `npm eject` - Eject from Create React App

## Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── Header.tsx       # Navigation header
│   ├── SearchForm.tsx   # Search input form
│   ├── QuestionCard.tsx # Question display card
│   ├── AnswerCard.tsx   # Answer display card
│   └── RecentSearches.tsx # Recent searches sidebar
├── pages/               # Page components
│   ├── HomePage.tsx     # Main search page
│   ├── QuestionPage.tsx # Individual question view
│   └── UserPage.tsx     # User management
├── services/            # API services
│   └── api.ts           # API client and types
└── App.tsx              # Main app component
```

## API Integration

The frontend communicates with the Elixir backend through the following endpoints:

- `GET /api/questions/search` - Search for questions
- `GET /api/questions/:id` - Get specific question
- `GET /api/questions/recent-searches` - Get recent searches
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `DELETE /api/users/:id` - Delete user

## Features

### Search Interface
- Real-time search with loading states
- AI reranking toggle for enhanced results
- Recent searches display for quick access

### Question Display
- Stack Overflow-inspired design
- Answer previews with vote counts
- Toggle between original and reranked answers
- Markdown rendering for rich content

### User Management
- Create new users
- View user list
- Delete users

## Styling

The application uses Tailwind CSS with custom Stack Overflow-inspired colors:

- `so-orange`: #f48024 (Stack Overflow orange)
- `so-blue`: #0074cc (Stack Overflow blue)
- `so-dark-blue`: #0a95ff (Hover states)
- `so-gray`: #6a737c (Text colors)
- `so-light-gray`: #f1f2f3 (Background)
- `so-border`: #d6d9dc (Borders)

## Docker Support

The frontend can be run in Docker using the provided Dockerfile:

```bash
docker build -t stack_overflow_frontend .
docker run -p 3000:3000 stack_overflow_frontend
```

Or use the docker-compose setup for the full stack:

```bash
docker-compose up
```

## Development

### Code Style
- TypeScript for type safety
- Functional components with hooks
- Tailwind CSS for styling
- Responsive design principles