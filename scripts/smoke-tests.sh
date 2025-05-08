#!/bin/bash
# Smoke tests for deployed application
# Usage: ./smoke-tests.sh https://your-app-url

set -e

URL=$1

if [ -z "$URL" ]; then
  echo "Error: URL parameter is required"
  echo "Usage: ./smoke-tests.sh https://your-app-url"
  exit 1
fi

echo "Running smoke tests against $URL"

# Test 1: Check if the application is responding
echo "Test 1: Checking if application responds..."
response=$(curl -s -o /dev/null -w "%{http_code}" $URL)
if [ "$response" -eq 200 ]; then
  echo "✅ Application is responding with HTTP 200"
else
  echo "❌ Application is not responding correctly. Got HTTP $response"
  exit 1
fi

# Test 2: Check if index.html contains expected content
echo "Test 2: Checking for expected content..."
if curl -s $URL | grep -q "<title"; then
  echo "✅ Found expected content in the response"
else
  echo "❌ Did not find expected content in the response"
  exit 1
fi

# Test 3: Check health endpoint
echo "Test 3: Checking health endpoint..."
health_response=$(curl -s -o /dev/null -w "%{http_code}" $URL/health)
if [ "$health_response" -eq 200 ]; then
  echo "✅ Health endpoint is responding with HTTP 200"
else
  echo "❌ Health endpoint is not responding correctly. Got HTTP $health_response"
  exit 1
fi

echo "All smoke tests passed! 🎉"
exit 0