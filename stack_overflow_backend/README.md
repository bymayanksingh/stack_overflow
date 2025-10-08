# Stack Overflow Clone - Backend API

A Phoenix-based REST API that provides Stack Overflow-like functionality with AI-powered answer reranking.

## Features

- **Question Search**: Search for questions on Stack Overflow using the public API.
- **Answer Reranking**: Use GEMINI API to rerank answers by relevance and accuracy.
- **User Management**: Create and manage users.
- **Search History**: Cache recent searches using ETS (Erlang Term Storage).
- **Database Persistence**: Store search history in PostgreSQL.

## Tech Stack

- **Framework**: Phoenix (Elixir).
- **Database**: PostgreSQL.
- **HTTP Client**: HTTPoison.
- **AI Integration**: GEMINI API.
- **Caching**: ETS (Erlang Term Storage).
- **JSON Parsing**: Jason.

## Prerequisites

- Elixir 1.15+ and Erlang/OTP 28+
- PostgreSQL 12+
- GEMINI API key

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd stack_overflow_clone
   ```

2. **Install dependencies**:
   ```bash
   mix deps.get
   ```

3. **Set up the database**:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

4. **Set up environment variables**:
   ```bash
   # Copy the example environment file
   cp ./env.example .env
   
   # Create/Edit .env and add your GEMINI API key
   # GEMINI_API_KEY=your-gemini-api-key-here
   ```

5. **Start the server**:
   ```bash
   mix phx.server
   ```

The API will be available at `http://localhost:4000` unless other `PORT` is specified in env variable.

## API Endpoints

### User Management

#### Create a User
```http
POST /api/users
Content-Type: application/json

{
  "user": {
    "email": "mayank@hginsights.com",
    "name": "Mayank Singh"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "email": "mayank@hginsights.com",
    "name": "Mayank Singh",
    "inserted_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
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

#### Update User
```http
PUT /api/users/:id
Content-Type: application/json

{
  "user": {
    "name": "Updated Name"
  }
}
```

#### Delete User
```http
DELETE /api/users/:id
```

### Question Search

#### Search Questions
```http
GET /api/questions/search?q=elixir&user_id=1&rerank=true
```

**Parameters:**
- `q` (required): Search query
- `user_id` (optional): User ID for search history tracking
- `rerank` (optional): Set to "true" to enable AI reranking

**Response:**
```json
{
  "data": [
    {
      "question_id": 12345,
      "title": "How to use Elixir pattern matching?",
      "body": "I'm new to Elixir and want to understand pattern matching...",
      "answers": [
        {
          "answer_id": 67890,
          "body": "Pattern matching in Elixir is...",
          "score": 15,
          "is_accepted": true
        }
      ],
      "reranked_answers": [
        {
          "answer_id": 67890,
          "body": "Pattern matching in Elixir is...",
          "score": 15,
          "is_accepted": true
        }
      ]
    }
  ],
  "meta": {
    "total": 1,
    "query": "elixir",
    "reranked": true
  }
}
```

#### Get Specific Question
```http
GET /api/questions/:id
```
Fetch a specific Stack Overflow question by its ID, including all answers.

**Parameters:**
- `id` (path): Stack Overflow question ID

**Example:**
```bash
curl -X GET "http://localhost:4000/api/questions/18011784"
```

**Response:**
```json
{
  "data": {
    "question_id": 18011784,
    "title": "Why are there two kinds of functions in Elixir?",
    "body": "...",
    "answers": [...],
    "answer_count": 9,
    "accepted_answer_id": 18023790
  }
}
```

**Error Response (Question Not Found):**
```json
{
  "error": "Question not found: \"Question not found\""
}
```

#### Get Recent Searches
```http
GET /api/questions/recent-searches?user_id=1
```

**Response:**
```json
{
  "data": {
    "cache": [
      {
        "query": "elixir pattern matching",
        "timestamp": "2024-01-01T12:00:00Z",
        "user_id": 1
      }
    ],
    "database": [
      {
        "id": 1,
        "query": "elixir pattern matching",
        "user_id": 1,
        "searched_at": "2024-01-01T12:00:00Z"
      }
    ]
  }
}
```

## Configuration

### Environment Variables

Create a `.env` file in the project root with the following variables:

- `GEMINI_API_KEY`: Your Google Gemini API key (required for reranking)

Example `.env` file:
```
GEMINI_API_KEY=your-gemini-api-key-here
```

### Database Configuration

The database configuration is in `config/dev.exs`:

```elixir
config :stack_overflow_clone, StackOverflowClone.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "stack_overflow_clone_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

## Testing with Postman

### Import Collection

1. Create a new collection in Postman
2. Add the following requests:

#### 1. Create User
- **Method**: POST
- **URL**: `http://localhost:4000/api/users`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
  ```json
  {
    "user": {
      "email": "test@example.com",
      "name": "Test User"
    }
  }
  ```

#### 2. Search Questions (Basic)
- **Method**: GET
- **URL**: `http://localhost:4000/api/questions/search?q=elixir`

#### 3. Search Questions (With Reranking)
- **Method**: GET
- **URL**: `http://localhost:4000/api/questions/search?q=elixir&user_id=1&rerank=true`

#### 4. Get Recent Searches
- **Method**: GET
- **URL**: `http://localhost:4000/api/questions/recent-searches?user_id=1`

### Testing Workflow

1. **Create a user** using the first request
2. **Note the user ID** from the response
3. **Search for questions** using the user ID
4. **Check recent searches** to see cached results
5. **View cache statistics** to monitor ETS usage

## Architecture

### Services

- **StackOverflowApi**: Handles communication with Stack Overflow API
- **GeminiService**: Manages Google Gemini API calls for answer reranking
- **CacheService**: Provides ETS-based caching for search history
- **StackOverflowService**: Main orchestrator service

### Database Schema

#### Users Table
- `id`: Primary key
- `email`: Unique email address
- `name`: User's display name
- `inserted_at`, `updated_at`: Timestamps

#### Questions Table
- `id`: Primary key
- `title`: Question title
- `body`: Question body
- `user_id`: Foreign key to users table
- `inserted_at`, `updated_at`: Timestamps

#### Search Entries Table
- `id`: Primary key
- `query`: Search query text
- `user_id`: Foreign key to users table
- `searched_at`: Timestamp of search
- `inserted_at`, `updated_at`: Timestamps

## Error Handling

The API returns appropriate HTTP status codes:

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server error

Error responses include details:

```json
{
  "error": "Query parameter 'q' is required"
}
```

## Development

### Running Tests
```bash
mix test
```

### Code Formatting
```bash
mix format
```

### Database Reset
```bash
mix ecto.reset
```

### Interactive Shell
```bash
iex -S mix
```