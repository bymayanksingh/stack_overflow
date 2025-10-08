import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { questionsApi, Question } from '../services/api';
import AnswerCard from '../components/AnswerCard';
import ReactMarkdown from 'react-markdown';
import rehypeRaw from 'rehype-raw';
import rehypeSanitize from 'rehype-sanitize';
import { Sparkles } from 'lucide-react';

const QuestionPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [question, setQuestion] = useState<Question | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showReranked, setShowReranked] = useState(false);
  const [reranking, setReranking] = useState(false);

  useEffect(() => {
    if (id) {
      fetchQuestion(parseInt(id), false);
    }
  }, [id]);

  const fetchQuestion = async (questionId: number, rerank: boolean = false) => {
    try {
      setLoading(true);
      const response = await questionsApi.getById(questionId, rerank);
      setQuestion(response.data);
      if (rerank && response.data.reranked_answers) {
        setShowReranked(true);
      }
    } catch (err) {
      setError('Failed to load question. Please try again.');
      console.error('Error fetching question:', err);
    } finally {
      setLoading(false);
    }
  };
  
  const handleRerank = async () => {
    if (!id || question?.reranked_answers) return;
    
    try {
      setReranking(true);
      // Fetch reranked data WITHOUT triggering full page loading state
      const response = await questionsApi.getById(parseInt(id), true);
      // Update only the question data, keeping the page rendered
      setQuestion(response.data);
      if (response.data.reranked_answers) {
        setShowReranked(true);
      }
    } catch (err) {
      console.error('Error reranking answers:', err);
      setError('Failed to rerank answers. Please try again.');
    } finally {
      setReranking(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-3/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-full mb-2"></div>
          <div className="h-4 bg-gray-200 rounded w-5/6 mb-4"></div>
          <div className="h-32 bg-gray-200 rounded mb-6"></div>
        </div>
      </div>
    );
  }

  if (error || !question) {
    return (
      <div className="max-w-4xl mx-auto">
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <p className="text-red-800">{error || 'Question not found'}</p>
        </div>
      </div>
    );
  }

  const answers = showReranked && question.reranked_answers 
    ? question.reranked_answers 
    : question.answers;
  
  // Create a map to find original rank for each answer
  const getOriginalRank = (answerId: number): number | undefined => {
    if (!question.answers) return undefined;
    const originalIndex = question.answers.findIndex(a => a.answer_id === answerId);
    return originalIndex >= 0 ? originalIndex + 1 : undefined;
  };

  return (
    <div className="max-w-4xl mx-auto">
      {/* Question Header */}
      <div className="bg-white border border-so-border rounded-lg p-6 mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-4">
          {question.title}
        </h1>
        
        <div className="flex items-center space-x-4 text-sm text-so-gray mb-4">
          <span>Asked by user</span>
          <span>•</span>
          <span>{question.answer_count} answer{question.answer_count !== 1 ? 's' : ''}</span>
        </div>

        <div className="prose max-w-none break-words">
          <ReactMarkdown
            rehypePlugins={[rehypeRaw, rehypeSanitize]}
            components={{
              pre: (props: any) => (
                <pre className="overflow-x-auto max-w-full">{props.children}</pre>
              ),
              code: (props: any) =>
                props.inline ? (
                  <code className="whitespace-pre-wrap break-words" {...props}>
                    {props.children}
                  </code>
                ) : (
                  <code className="block whitespace-pre overflow-x-auto" {...props}>
                    {props.children}
                  </code>
                )
            }}
          >
            {question.body}
          </ReactMarkdown>
        </div>
      </div>

      {/* Answers Section */}
      <div className="bg-white border border-so-border rounded-lg p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">
            {answers.length} Answer{answers.length !== 1 ? 's' : ''}
          </h2>
          
          <div className="flex items-center gap-3">
            {!question.reranked_answers && (
              <button
                onClick={handleRerank}
                disabled={reranking}
                className={`px-4 py-2 rounded-md text-sm font-medium ${
                  reranking
                    ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                    : 'bg-so-blue text-white hover:bg-blue-700'
                }`}
              >
                {reranking ? 'Reranking...' : 'Rerank answers using AI'}
              </button>
            )}
            
            {question.reranked_answers && (
              <button
                onClick={() => setShowReranked(!showReranked)}
                className={`px-4 py-2 rounded-md text-sm font-medium ${
                  showReranked
                    ? 'bg-so-blue text-white'
                    : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
              >
                {showReranked ? 'Show Original Order' : 'Show AI-Reranked'}
              </button>
            )}
          </div>
        </div>

        {answers.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <p>No answers yet. Be the first to answer this question!</p>
          </div>
        ) : (
          <div className="relative">
            {/* Loading overlay for reranking - only covers answers section */}
            {reranking && (
              <div className="absolute inset-0 bg-white bg-opacity-90 z-10 flex items-center justify-center rounded-lg">
                <div className="text-center">
                  <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mb-4"></div>
                  <p className="text-purple-700 font-semibold flex items-center space-x-2">
                    <Sparkles className="w-5 h-5 animate-pulse" />
                    <span>AI is reranking answers based on relevance...</span>
                  </p>
                </div>
              </div>
            )}
            
            <>
              {/* Current View Indicator */}
              {question.reranked_answers && (
                <div className={`mb-4 p-3 rounded-lg border-2 ${
                  showReranked 
                    ? 'bg-gradient-to-r from-purple-50 to-pink-50 border-purple-300' 
                    : 'bg-blue-50 border-blue-300'
                }`}>
                  <div className="flex items-center justify-center space-x-2">
                    {showReranked && <Sparkles className="w-4 h-4 text-purple-600" />}
                    <span className={`text-sm font-semibold ${
                      showReranked ? 'text-purple-700' : 'text-blue-700'
                    }`}>
                      {showReranked 
                        ? '✨ Viewing AI-Reranked Answers (sorted by relevance using Gemini AI)' 
                        : '📊 Viewing Original Order (sorted by Stack Overflow votes)'}
                    </span>
                  </div>
                </div>
              )}
              
              <div className="space-y-6">
                {answers.map((answer, index) => (
                  <AnswerCard
                    key={answer.answer_id}
                    answer={answer}
                    isAccepted={answer.is_accepted}
                    rank={index + 1}
                    showReranked={showReranked}
                    originalRank={showReranked ? getOriginalRank(answer.answer_id) : undefined}
                  />
                ))}
              </div>
            </>
          </div>
        )}
      </div>
    </div>
  );
};

export default QuestionPage;
