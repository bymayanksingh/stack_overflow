import React from 'react';
import { MessageSquare, ThumbsUp, CheckCircle } from 'lucide-react';
import { Question } from '../services/api';
import ReactMarkdown from 'react-markdown';
import rehypeRaw from 'rehype-raw';
import rehypeSanitize from 'rehype-sanitize';

interface QuestionCardProps {
  question: Question;
  showReranked: boolean;
  onClick: () => void;
}

const QuestionCard: React.FC<QuestionCardProps> = ({ question, showReranked, onClick }) => {
  const answers = showReranked && question.reranked_answers 
    ? question.reranked_answers 
    : question.answers;

  const truncateText = (text: string, maxLength: number = 200) => {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  };

  return (
    <div 
      className="bg-white border border-so-border rounded-lg p-6 hover:shadow-md transition-shadow cursor-pointer"
      onClick={onClick}
    >
      <div className="flex space-x-4">
        {/* Stats */}
        <div className="flex flex-col items-center space-y-2 text-sm text-so-gray">
          <div className="flex items-center space-x-1">
            <ThumbsUp className="w-4 h-4" />
            <span>{question.answers.reduce((sum, answer) => sum + answer.score, 0)}</span>
          </div>
          <div className="flex items-center space-x-1">
            <MessageSquare className="w-4 h-4" />
            <span>{question.answer_count}</span>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-so-blue hover:text-so-dark-blue mb-2">
            {question.title}
          </h3>
          
          <div className="text-gray-700 mb-4 line-clamp-3 prose max-w-none break-words">
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
              {truncateText(question.body)}
            </ReactMarkdown>
          </div>

          {/* Answers Preview */}
          {answers.length > 0 && (
            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-sm text-so-gray">
                <span className="font-medium">
                  {showReranked && question.reranked_answers ? 'AI-Reranked' : 'Original'} Answers:
                </span>
              </div>
              
              {answers.slice(0, 2).map((answer, index) => (
                <div key={answer.answer_id} className="bg-so-light-gray p-3 rounded border-l-4 border-so-blue">
                  <div className="flex items-start space-x-2">
                    {answer.is_accepted && (
                      <CheckCircle className="w-4 h-4 text-green-500 mt-1 flex-shrink-0" />
                    )}
                    <div className="flex-1">
                      <div className="text-sm text-gray-700 line-clamp-2 prose max-w-none break-words">
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
                          {truncateText(answer.body, 150)}
                        </ReactMarkdown>
                      </div>
                      <div className="flex items-center space-x-4 mt-2 text-xs text-so-gray">
                        <span className="flex items-center space-x-1">
                          <ThumbsUp className="w-3 h-3" />
                          <span>{answer.score}</span>
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
              
              {answers.length > 2 && (
                <div className="text-sm text-so-blue hover:text-so-dark-blue">
                  +{answers.length - 2} more answer{answers.length - 2 !== 1 ? 's' : ''}
                </div>
              )}
            </div>
          )}

          {/* Tags */}
          <div className="flex flex-wrap gap-2 mt-4">
            <span className="px-2 py-1 bg-so-light-gray text-so-gray text-xs rounded">
              programming
            </span>
            <span className="px-2 py-1 bg-so-light-gray text-so-gray text-xs rounded">
              help
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default QuestionCard;
