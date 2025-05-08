#!/bin/bash
# Monitor deployment health for a specified duration
# Usage: ./monitor-deployment.sh https://your-app-url 300

set -e

URL=$1
DURATION=$2  # in seconds

if [ -z "$URL" ] || [ -z "$DURATION" ]; then
  echo "Error: URL and DURATION parameters are required"
  echo "Usage: ./monitor-deployment.sh https://your-app-url 300"
  exit 1
fi

echo "Monitoring $URL for $DURATION seconds..."

END_TIME=$(($(date +%s) + DURATION))
CHECK_INTERVAL=30  # Check every 30 seconds
FAILURES=0
MAX_FAILURES=3

while [ $(date +%s) -lt $END_TIME ]; do
  echo "$(date): Checking application health..."
  
  response=$(curl -s -o /dev/null -w "%{http_code}" $URL/health)
  
  if [ "$response" -eq 200 ]; then
    echo "✅ Application is healthy"
    FAILURES=0
  else
    echo "⚠️ Application returned non-200 response: $response"
    FAILURES=$((FAILURES + 1))
    
    if [ $FAILURES -ge $MAX_FAILURES ]; then
      echo "❌ Application failed health check $MAX_FAILURES times in a row"
      echo "Monitoring failed!"
      exit 1
    fi
  fi
  
  # Sleep for the check interval, but check if we've exceeded the end time
  sleep_time=$CHECK_INTERVAL
  current_time=$(date +%s)
  time_left=$((END_TIME - current_time))
  
  if [ $time_left -lt $sleep_time ]; then
    sleep_time=$time_left
  fi
  
  if [ $sleep_time -gt 0 ]; then
    sleep $sleep_time
  fi
done

echo "✅ Monitoring completed successfully for $DURATION seconds"
echo "Deployment is stable! 🎉"
exit 0