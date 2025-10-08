import React, { useState, useEffect } from 'react';
import { questionsApi, Question, User } from '../services/api';
import QuestionCard from '../components/QuestionCard';
import SearchForm from '../components/SearchForm';
import RecentSearches from '../components/RecentSearches';
import { userApi } from '../services/api';

const HomePage: React.FC = () => {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [rateLimitNote, setRateLimitNote] = useState<string | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [showReranked, setShowReranked] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    // Load users and ensure a default exists
    initUsers();
  }, []);

  const initUsers = async () => {
    try {
      const res = await userApi.getAll();
      if (res.data.length > 0) {
        setUsers(res.data);
        setCurrentUser(res.data[0]);
      } else {
        const newUser = await userApi.create({
          email: 'demo@example.com',
          name: 'Demo User'
        });
        setUsers([newUser.data]);
        setCurrentUser(newUser.data);
      }
    } catch (error) {
      console.error('Error creating user:', error);
    }
  };

  const handleSearch = async (query: string, rerank: boolean = false) => {
    if (!query.trim()) return;

    setLoading(true);
    setError(null);
    setRateLimitNote(null);
    setSearchQuery(query);

    try {
      const response = await questionsApi.search(
        query,
        currentUser?.id,
        rerank
      );
      setQuestions(response.data);
      // Surface rate limit info from backend if present
      // @ts-ignore meta may include note
      if ((response as any).meta && (response as any).meta.note) {
        setRateLimitNote((response as any).meta.note as string);
      } else {
        setRateLimitNote(null);
      }
      setShowReranked(rerank);
    } catch (err) {
      setError('Failed to search questions. Please try again.');
      console.error('Search error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleQuestionClick = (questionId: number) => {
    window.open(`/question/${questionId}`, '_blank');
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Welcome to StackOverflow
        </h1>
        <p className="text-gray-600 mb-4">
          Search for programming questions and get AI-powered answer reranking
        </p>
        
        <SearchForm
          onSearch={handleSearch}
          loading={loading}
          users={users}
          selectedUserId={currentUser?.id}
          onUserChange={(id) => {
            const user = users.find(u => u.id === id) || null;
            setCurrentUser(user);
          }}
        />
      </div>

      {currentUser && (
        <div className="mb-8">
          <RecentSearches userId={currentUser.id} onSearch={handleSearch} />
        </div>
      )}

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4 mb-6">
          <p className="text-red-800">{error}</p>
        </div>
      )}

      {rateLimitNote && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4 mb-6">
          <p className="text-yellow-800 text-sm">{rateLimitNote}</p>
        </div>
      )}

      {questions.length > 0 && (
        <div className="mb-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-gray-900">
              {showReranked ? 'AI-Reranked Results' : 'Search Results'}
            </h2>
            <div className="flex items-center gap-3">
              <span className="text-sm text-gray-600">
                {questions.length} question{questions.length !== 1 ? 's' : ''} found
              </span>
              {questions.some(q => q.reranked_answers) && (
                <button
                  onClick={() => setShowReranked(!showReranked)}
                  className={`px-3 py-1 rounded-md text-sm font-medium ${
                    showReranked
                      ? 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                      : 'bg-so-blue text-white'
                  }`}
                >
                  {showReranked ? 'Show Original' : 'Show Reranked Order'}
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {loading && (
        <div className="flex justify-center items-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-so-blue"></div>
        </div>
      )}

      <div className="space-y-4">
        {questions.map((question) => (
          <QuestionCard
            key={question.question_id}
            question={question}
            showReranked={showReranked}
            onClick={() => handleQuestionClick(question.question_id)}
          />
        ))}
      </div>

      {!loading && questions.length === 0 && searchQuery && (
        <div className="text-center py-12">
          <p className="text-gray-500 text-lg">No questions found for "{searchQuery}"</p>
          <p className="text-gray-400 text-sm mt-2">
            Try different keywords or check your spelling
          </p>
        </div>
      )}
    </div>
  );
};

export default HomePage;
