#!/bin/bash

# Start the Prefect server using the expect script in the background
/usr/bin/expect /app/start_prefect_server.expect &
sleep 90
# Wait for the server to be ready
echo "Waiting for Prefect server to start..."

# Add an additional delay to ensure stability
sleep 10

echo "Prefect server is up and running!"

# Run your Prefect flow
python /app/orchestration/prefect_pipeline.py
