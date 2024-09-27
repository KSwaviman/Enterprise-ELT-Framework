#!/bin/bash

# Start the Prefect server using the expect script in the background
/usr/bin/expect /app/start_prefect_server.expect &
sleep 90
# Wait for the server to be ready
echo "Waiting for Prefect server to start..."
# MAX_RETRIES=36  # Total wait time: 36 * 5 = 180 seconds
# RETRY_COUNT=0

# # Ensure server API health endpoint is up before proceeding
# # until curl --output /dev/null --silent --head --fail http://127.0.0.1:4200/api/health; do
# until curl --output /dev/null --silent --head --fail http://localhost:8081/api/health; do
#     echo "Prefect server not yet available, retrying in 5 seconds..."
#     sleep 5
#     RETRY_COUNT=$((RETRY_COUNT+1))
#     if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
#         echo "Prefect server did not start within expected time."
#         exit 1
#     fi
# done

echo "Prefect server is up and running!"

# Add an additional delay to ensure stability
sleep 10

# Run your Prefect flow
python /app/orchestration/prefect_pipeline.py
