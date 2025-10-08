import React, { useState, useEffect, useCallback } from 'react';
import { Clock, Search } from 'lucide-react';
import { questionsApi } from '../services/api';

interface RecentSearchesProps {
  userId: number;
  onSearch: (query: string, rerank: boolean) => void;
}

interface SearchEntry {
  id: number;
  query: string;
  user_id: number;
  searched_at: string;
}

const RecentSearches: React.FC<RecentSearchesProps> = ({ userId, onSearch }) => {
  const [recentSearches, setRecentSearches] = useState<SearchEntry[]>([]);
  const [allSearches, setAllSearches] = useState<SearchEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAll, setShowAll] = useState(false);

  const fetchRecent = useCallback(async () => {
    await fetchRecentSearches();
  }, [userId]);

  useEffect(() => {
    fetchRecent();
  }, [fetchRecent]);

  const fetchRecentSearches = async () => {
    try {
      const response = await questionsApi.getRecentSearches(userId);
      // cache: ETS recent 5; database: full history
      setRecentSearches(response.data.cache
        .map(c => ({
          id: new Date(c.timestamp).getTime(),
          query: c.query,
          user_id: c.user_id,
          searched_at: c.timestamp
        }))
        .slice(0, 5));
      setAllSearches(response.data.database.map(d => ({
        id: d.id,
        query: d.query,
        user_id: d.user_id,
        searched_at: d.searched_at
      })));
    } catch (error) {
      console.error('Error fetching recent searches:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearchClick = (query: string) => {
    onSearch(query, false);
  };

  if (loading) {
    return (
      <div className="bg-white border border-so-border rounded-lg p-4">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded w-1/4 mb-3"></div>
          <div className="space-y-2">
            <div className="h-3 bg-gray-200 rounded w-3/4"></div>
            <div className="h-3 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!showAll && recentSearches.length === 0 && allSearches.length === 0) {
    return null;
  }

  return (
    <div className="bg-white border border-so-border rounded-lg p-4">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center space-x-2">
          <Clock className="w-4 h-4 text-so-gray" />
          <h3 className="text-sm font-medium text-gray-700">
            {showAll ? 'All Searches' : 'Recent Searches'}
          </h3>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowAll(false)}
            className={`text-xs px-2 py-1 rounded ${!showAll ? 'bg-so-blue text-white' : 'bg-gray-200 text-gray-700'}`}
          >Recent 5</button>
          <button
            onClick={() => setShowAll(true)}
            className={`text-xs px-2 py-1 rounded ${showAll ? 'bg-so-blue text-white' : 'bg-gray-200 text-gray-700'}`}
          >All</button>
        </div>
      </div>
      
      <div className="space-y-2">
        {(showAll ? allSearches : recentSearches).map((search) => (
          <button
            key={`${showAll ? 'db' : 'cache'}-${search.id}-${search.searched_at}`}
            onClick={() => handleSearchClick(search.query)}
            className="flex items-center space-x-2 w-full text-left p-2 hover:bg-so-light-gray rounded text-sm text-so-gray hover:text-so-blue transition-colors"
          >
            <Search className="w-3 h-3 flex-shrink-0" />
            <span className="truncate">{search.query}</span>
            <span className="text-xs text-gray-400 ml-auto">
              {new Date(search.searched_at).toLocaleDateString()}
            </span>
          </button>
        ))}
      </div>

      {!showAll && allSearches.length > 5 && (
        <div className="mt-3">
          <button
            onClick={() => setShowAll(true)}
            className="w-full text-center text-sm text-so-blue hover:text-so-dark-blue"
          >
            Show all searches
          </button>
        </div>
      )}
    </div>
  );
};

export default RecentSearches;
