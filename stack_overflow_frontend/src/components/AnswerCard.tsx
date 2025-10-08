import React from 'react';
import { ThumbsUp, CheckCircle, Sparkles } from 'lucide-react';
import { Answer } from '../services/api';
import ReactMarkdown from 'react-markdown';
import rehypeRaw from 'rehype-raw';
import rehypeSanitize from 'rehype-sanitize';

interface AnswerCardProps {
  answer: Answer;
  isAccepted: boolean;
  rank: number;
  showReranked: boolean;
  originalRank?: number;
}

const AnswerCard: React.FC<AnswerCardProps> = ({ 
  answer, 
  isAccepted, 
  rank, 
  showReranked,
  originalRank
}) => {
  return (
    <div className={`border rounded-lg p-4 ${
      isAccepted ? 'border-green-200 bg-green-50' : 'border-so-border'
    }`}>
      <div className="flex items-start space-x-4">
        {/* Vote Section */}
        <div className="flex flex-col items-center space-y-2">
          <button className="flex items-center space-x-1 text-so-gray hover:text-so-blue">
            <ThumbsUp className="w-4 h-4" />
            <span className="text-sm font-medium">{answer.score}</span>
          </button>
          {isAccepted && (
            <CheckCircle className="w-5 h-5 text-green-500" />
          )}
        </div>

        {/* Answer Content */}
        <div className="flex-1">
          <div className="flex items-center space-x-2 mb-3">
            {/* Show both rank badges when in reranked view */}
            {showReranked && originalRank ? (
              <>
                <div className="flex items-center space-x-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white px-3 py-1 rounded-full text-xs font-bold shadow-md">
                  <Sparkles className="w-3 h-3" />
                  <span>AI Rank #{rank}</span>
                </div>
                <div className="flex items-center space-x-1 bg-gray-400 text-white px-3 py-1 rounded-full text-xs font-medium">
                  <span>Was #{originalRank}</span>
                </div>
                {rank < originalRank && (
                  <span className="text-green-600 text-xs font-bold">↑ Moved up</span>
                )}
                {rank > originalRank && (
                  <span className="text-orange-600 text-xs font-bold">↓ Moved down</span>
                )}
              </>
            ) : (
              <div className="flex items-center space-x-1 bg-blue-500 text-white px-3 py-1 rounded-full text-xs font-bold">
                <span>Original #{rank}</span>
              </div>
            )}
            
            {isAccepted && (
              <div className="flex items-center space-x-1 bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium">
                <CheckCircle className="w-3 h-3" />
                <span>Accepted</span>
              </div>
            )}
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
              {answer.body}
            </ReactMarkdown>
          </div>

          <div className="flex items-center justify-between mt-4 pt-3 border-t border-gray-200">
            <div className="flex items-center space-x-4 text-sm text-so-gray">
              <span>Answered by user</span>
              <span>•</span>
              <span>{answer.score} vote{answer.score !== 1 ? 's' : ''}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AnswerCard;
