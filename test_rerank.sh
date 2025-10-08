#!/bin/bash

# Test script for search_and_rerank_questions endpoint
# This script tests if the Gemini API calls are being made

echo "🧪 Testing search_and_rerank_questions endpoint..."
echo "================================================"

# Test parameters
BASE_URL="http://localhost:4000"
QUERY="javascript async await"
USER_ID="5"  # Using the user ID from your data
RERANK="true"

echo "📋 Test Parameters:"
echo "  Query: $QUERY"
echo "  User ID: $USER_ID"
echo "  Rerank: $RERANK"
echo "  Base URL: $BASE_URL"
echo ""

# Make the API call
echo "🚀 Making API call to search_and_rerank_questions..."
echo ""

curl -X GET \
  "$BASE_URL/api/questions/search?q=$QUERY&user_id=$USER_ID&rerank=$RERANK" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -w "\n\n📊 Response Details:\nHTTP Status: %{http_code}\nTotal Time: %{time_total}s\n" \
  -v

echo ""
echo "================================================"
echo "✅ Test completed!"
echo ""
echo "📝 To check if Gemini API calls were made, look for these log messages in your Phoenix server:"
echo "   🔍 SEARCH_AND_RERANK: Starting search_and_rerank_questions"
echo "   🔄 RERANK_QUESTION: Processing question"
echo "   🔄 GEMINI RERANKING: Starting rerank for question"
echo "   🔄 GEMINI API CALL: Making request to Gemini API"
echo "   ✅ GEMINI API SUCCESS: Received response from Gemini API"
echo ""
echo "If you see these logs, the Gemini API integration is working!"
