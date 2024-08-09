#!/bin/bash

# start-ui.sh - start the app

# Function to check the health of the API.
check_api_health() {
  for (( i=1; i<=${HEALTH_CHECK_RETRIES}; i++ )); do
    if curl --max-time "${HEALTH_CHECK_TIMEOUT}" -s "${HEALTH_CHECK_URL}"; then
      return 0  # Success
    else
      echo "Waiting for groupings-api to be available... (Attempt $i/${HEALTH_CHECK_RETRIES})"
      sleep "${HEALTH_CHECK_INTERVAL}"
    fi
  done
  return 1  # Failure
}

# Check the health of the API and start the UI if successful.
if check_api_health; then
  cd groupings
  ./mvnw spring-boot:run
else
  echo "ERROR: groupings-api did not become available after "${HEALTH_CHECK_RETRIES}" attempts."
  exit 1
fi