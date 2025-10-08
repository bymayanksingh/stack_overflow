#!/bin/bash

# Simple curl test for search_and_rerank_questions
echo "🧪 Simple test for search_and_rerank_questions endpoint"
echo "======================================================"

curl -X GET \
  "http://localhost:4000/api/questions/search?q=javascript%20async%20await&user_id=5&rerank=true" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -w "\n\n HTTP Status: %{http_code}\n Total Time: %{time_total}s\n"

echo ""
echo "Test completed! Check your Phoenix server logs for Gemini API calls."
