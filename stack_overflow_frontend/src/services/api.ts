import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:4000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Types
export interface User {
  id: number;
  email: string;
  name: string;
  inserted_at: string;
  updated_at: string;
}

export interface Answer {
  answer_id: number;
  body: string;
  score: number;
  is_accepted: boolean;
}

export interface Question {
  question_id: number;
  title: string;
  body: string;
  answers: Answer[];
  reranked_answers?: Answer[];
  answer_count: number;
  accepted_answer_id?: number;
}

export interface SearchResponse {
  data: Question[];
  meta: {
    total: number;
    query: string;
    reranked: boolean;
  };
}

export interface RecentSearchesResponse {
  data: {
    cache: Array<{
      query: string;
      timestamp: string;
      user_id: number;
    }>;
    database: Array<{
      id: number;
      query: string;
      user_id: number;
      searched_at: string;
    }>;
  };
}

// User API
export const userApi = {
  create: async (userData: { email: string; name: string }): Promise<{ data: User }> => {
    const response = await api.post('/users', { user: userData });
    return response.data;
  },

  getAll: async (): Promise<{ data: User[] }> => {
    const response = await api.get('/users');
    return response.data;
  },

  getById: async (id: number): Promise<{ data: User }> => {
    const response = await api.get(`/users/${id}`);
    return response.data;
  },

  update: async (id: number, userData: Partial<User>): Promise<{ data: User }> => {
    const response = await api.put(`/users/${id}`, { user: userData });
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await api.delete(`/users/${id}`);
  },
};

// Questions API
export const questionsApi = {
  search: async (
    query: string,
    userId?: number,
    rerank: boolean = false
  ): Promise<SearchResponse> => {
    const params = new URLSearchParams({ q: query });
    if (userId) params.append('user_id', userId.toString());
    if (rerank) params.append('rerank', 'true');

    const response = await api.get(`/questions/search?${params}`);
    return response.data;
  },

  getById: async (id: number, rerank: boolean = false): Promise<{ data: Question }> => {
    const params = new URLSearchParams();
    if (rerank) params.append('rerank', 'true');
    
    const url = params.toString() ? `/questions/${id}?${params}` : `/questions/${id}`;
    const response = await api.get(url);
    return response.data;
  },

  getRecentSearches: async (userId: number): Promise<RecentSearchesResponse> => {
    const response = await api.get(`/questions/recent-searches?user_id=${userId}`);
    return response.data;
  },
};

export default api;
