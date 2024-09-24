#!/bin/bash

# Set the PREFECT_API_URL environment variable
export PREFECT_API_URL="http://127.0.0.1:4200/api"

# Start the Prefect server with the UI enabled and specify the API URL
prefect server start --host 0.0.0.0 --ui --api-url "http://127.0.0.1:4200/api" &

# Wait for the server to be ready
echo "Waiting for Prefect server to start..."

MAX_RETRIES=24  # Adjust as needed
RETRY_COUNT=0

# Use the correct health check endpoint
until curl --output /dev/null --silent --head --fail http://127.0.0.1:4200/api/health
do
    echo "Prefect server not yet available, retrying in 5 seconds..."
    sleep 5
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Prefect server did not start within expected time."
        exit 1
    fi
done

echo "Prefect server is up and running!"

# Run your flow script
python orchestration/prefect_pipeline.py
