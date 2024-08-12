#!/bin/bash

# start-ui.sh - start the Groupings UI

# Function to check API availability.
check_api_health() {
  for (( i=1; i<=${HEALTH_CHECK_RETRIES}; i++ )); do
    if curl -I http://groupings-api:8081/uhgroupingsapi/api/groupings/v2.1/ 2>/dev/null | grep -q "HTTP/1.1 200"; then
      return 0
    else
      echo "Waiting for the API... (attempt $i of ${HEALTH_CHECK_RETRIES})"
      sleep "${HEALTH_CHECK_INTERVAL}"
    fi
  done
  return 1
}

echo "Health check URL: ${HEALTH_CHECK_URL}"

# Delay the UI startup until the API startup finishes.
if check_api_health; then
  cd groupings
  ./mvnw spring-boot:run -Dspring-boot.run.profiles=dockerhost
else
  echo "ERROR: API not found after ${HEALTH_CHECK_RETRIES} attempts."
  exit 1
fi
