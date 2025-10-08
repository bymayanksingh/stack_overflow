# Stack Overflow Clone - Full Stack Application

Stack Overflow clone built with Elixir/Phoenix backend and React frontend, featuring AI-powered answer reranking using Google Gemini API.

## Features

### Backend (Elixir/Phoenix)
- **RESTful API** with comprehensive endpoints
- **Stack Overflow API Integration** for real question data
- **AI-Powered Reranking** using Google Gemini API
- **User Management** with PostgreSQL
- **Search History Caching** using Eralng Term Storage (ETS)
- **Error Handling** with proper HTTP status codes

### Frontend (React/TypeScript)
- **Modern React 18** with TypeScript
- **Stack Overflow-Inspired UI** with Tailwind CSS
- **Real-time Search** with loading states
- **AI Reranking Toggle** for enhanced results
- **User Management** interface
- **Recent Searches** component to toggle between recent searches (via cache) & all searches (via database)

### AI Integration
- **Google Gemini API** for answer reranking
- **Toggle Between Original and Reranked** results

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend│    │  Phoenix Backend│    │  PostgreSQL DB │
│   (Port 3000)   │◄──►│   (Port 4000)   │◄──►│   (Port 5432)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Stack Overflow │
                       │      API        │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Google Gemini  │
                       │      API        │
                       └─────────────────┘
```

## Tech Stack

### Backend
- **Elixir 1.15+** with Phoenix 1.8
- **PostgreSQL** for data persistence
- **HTTPoison** for HTTP requests
- **Gemini API** for AI reranking
- **ETS** for in-memory caching
- **Jason** for JSON handling

### Frontend
- **React 18** with TypeScript
- **Tailwind CSS** for styling
- **React Router** for navigation
- **Axios** for API communication
- **Lucide React** for icons
- **React Markdown** for content

## Quick Start

### Prerequisites
- Elixir 1.15+ and Erlang/OTP 28+
- Node.js 18+
- PostgreSQL 12+
- Google Gemini API key

### Option 1: Docker (Recommended)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd insights
   ```

2. **Set up environment variables**:
   ```bash
   cp stack_overflow_backend/env.example .env
   # Edit .env and add your GEMINI_API_KEY
   ```

3. **Start all services**:
   ```bash
   docker-compose up
   ```

4. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:4000
   - Database: localhost:5432

### Option 2: Manual Setup

#### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd stack_overflow_backend
   ```

2. **Install dependencies**:
   ```bash
   mix deps.get
   ```

3. **Set up database**:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

4. **Set environment variables**:
   ```bash
   cp env.example .env
   # Add your GEMINI_API_KEY to .env
   ```

5. **Start the server**:
   ```bash
   mix phx.server
   ```

#### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd stack_overflow_frontend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set environment variables**:
   ```bash
   echo "REACT_APP_API_URL=http://localhost:4000/api" > .env
   ```

4. **Start the development server**:
   ```bash
   npm start
   ```

## API Documentation

### User Management

#### Create User
```http
POST /api/users
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### Get All Users
```http
GET /api/users
```

#### Get User by ID
```http
GET /api/users/:id
```

### Question Search

#### Search Questions
```http
GET /api/questions/search?q=elixir&user_id=1&rerank=true
```

**Parameters:**
- `q` (required): Search query
- `user_id` (optional): User ID for search history
- `rerank` (optional): Enable AI reranking

#### Get Specific Question
```http
GET /api/questions/:id
```

#### Get Recent Searches
```http
GET /api/questions/recent-searches?user_id=1
```

## Frontend Features

### Search Interface
- Clean, Stack Overflow-inspired design
- Real-time search with loading states
- AI reranking toggle
- Recent searches component

### Question Display
- Dedicated question cards
- Answer previews with vote counts (fetched from stack overflow)
- Toggle between original and reranked answers
- Markdown / HTML / Rich Content rendering.

### User Management
- Create new users
- View user list
- Delete users

## Configuration

### Environment Variables

#### Backend (.env)
```bash
GEMINI_API_KEY=your-gemini-api-key-here
```

#### Frontend (.env)
```bash
REACT_APP_API_URL=http://localhost:4000/api
```

### Database Configuration
The database is configured in `stack_overflow_clone/config/dev.exs`:
```elixir
config :stack_overflow_clone, StackOverflowClone.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "stack_overflow_clone_dev"
```

## 🧪 Testing

### Backend Tests
```bash
cd stack_overflow_clone
mix test
```

## Deployment

### Docker Deployment
```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**:
   - Ensure PostgreSQL is running
   - Check database credentials
   - Run `mix ecto.create` and `mix ecto.migrate`

2. **API Connection Issues**:
   - Verify backend is running on port 4000
   - Check CORS configuration
   - Verify API endpoints

3. **Gemini API Issues**:
   - Ensure API key is set correctly
   - Check API quota and limits
   - Verify network connectivity

### Getting Help
- Check the logs: `docker-compose logs`
- Verify environment variables
- Test API endpoints manually (using postman collection as shared in the backend directory)
- Check browser console for frontend errors

## Future Enhancements

- [ ] User authentication and authorization
- [ ] Advanced search filters
- [ ] Tag-based organization
- [ ] Mobile app support
- [ ] Performance optimizations
- [ ] Advanced AI features
