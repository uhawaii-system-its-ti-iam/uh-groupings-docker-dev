#!/bin/bash

# start-ui.sh - start the Groupings UI

# Function to check API availability.
check_api_health() {
  for (( i=1; i<=${HEALTH_CHECK_RETRIES}; i++ )); do
    if curl --max-time "${HEALTH_CHECK_TIMEOUT}" -s "${HEALTH_CHECK_URL}"; then
      return 0
    else
      echo "Waiting for API... (attempt $i of ${HEALTH_CHECK_RETRIES})"
      sleep "${HEALTH_CHECK_INTERVAL}"
    fi
  done
  return 1
}

# Delay the UI startup until the API startup finishes.
if check_api_health; then
  cd groupings
  ./mvnw spring-boot:run
else
  echo "ERROR: API not found after ${HEALTH_CHECK_RETRIES} attempts."
  exit 1
fi
