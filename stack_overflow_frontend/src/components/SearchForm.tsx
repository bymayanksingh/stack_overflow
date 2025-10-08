import React, { useState } from 'react';
import { Search } from 'lucide-react';
import type { User } from '../services/api';

interface SearchFormProps {
  onSearch: (query: string, rerank: boolean) => void;
  loading: boolean;
  users?: User[];
  selectedUserId?: number;
  onUserChange?: (id: number) => void;
}

const SearchForm: React.FC<SearchFormProps> = ({ onSearch, loading, users = [], selectedUserId, onUserChange }) => {
  const [query, setQuery] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      onSearch(query.trim(), false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="flex items-center gap-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-so-gray w-5 h-5" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search for programming questions..."
            className="w-full pl-10 pr-4 py-3 border border-so-border rounded-lg focus:outline-none focus:ring-2 focus:ring-so-blue focus:border-transparent text-lg"
            disabled={loading}
          />
        </div>
        {users.length > 0 && (
          <select
            aria-label="Search as user"
            value={selectedUserId || users[0]?.id}
            onChange={(e) => onUserChange && onUserChange(Number(e.target.value))}
            disabled={loading}
            className="w-72 px-3 py-3 border border-so-border rounded-lg focus:outline-none focus:ring-2 focus:ring-so-blue focus:border-transparent bg-white"
          >
            {users.map(u => (
              <option key={u.id} value={u.id}>{u.name} ({u.email})</option>
            ))}
          </select>
        )}
        <button
          type="submit"
          disabled={loading || !query.trim()}
          className="px-6 py-3 bg-so-blue text-white rounded-lg hover:bg-so-dark-blue disabled:opacity-50 disabled:cursor-not-allowed font-medium"
        >
          {loading ? 'Searching...' : 'Search'}
        </button>
      </div>
      
    </form>
  );
};

export default SearchForm;
