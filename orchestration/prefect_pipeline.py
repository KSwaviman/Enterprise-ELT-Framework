import os

# Set environment variables before importing Prefect
os.environ["PREFECT_API_URL"] = "http://127.0.0.1:4200/api"
os.environ["PREFECT_LOGGING_LEVEL"] = "DEBUG"

# Now import Prefect and other modules
from prefect import flow, task
import subprocess
import requests
from requests.auth import HTTPBasicAuth
import logging  # Add this line
from prefect.logging import get_logger

logger = get_logger()
logger.setLevel(logging.DEBUG)

@task
def trigger_airbyte_sync():
    airbyte_url = "http://host.docker.internal:8000/api/v1/connections/sync"
    connection_id = "faeebcd1-a142-4815-aa01-5fdb4c84a779"
    
    username = "airbyte"  # Replace with your Airbyte username
    password = "password"  # Replace with your Airbyte password
    
    # Trigger Airbyte sync via API with Basic Authentication
    response = requests.post(
        airbyte_url, 
        json={"connectionId": connection_id}, 
        auth=HTTPBasicAuth(username, password)
    )
    
    if response.status_code == 200:
        logger.info("Airbyte sync triggered successfully")
    else:
        logger.error(f"Failed to trigger Airbyte sync: {response.status_code}, {response.text}")
        response.raise_for_status()

@task
def run_dbt_via_subprocess():
    command = ["dbt", "run"]
    env = os.environ.copy()
    env["DBT_PROFILES_DIR"] = "/root/.dbt"  # Ensure the correct path
    
    try:
        result = subprocess.run(
            command, 
            cwd="/app", 
            env=env, 
            check=True, 
            text=True, 
            capture_output=True
        )
        logger.info("DBT Output:\n" + result.stdout)  # Log DBT output
        if result.stderr:
            logger.warning("DBT Errors:\n" + result.stderr)  # Log any DBT errors
    except subprocess.CalledProcessError as e:
        logger.error(f"Error running dbt: {e.stderr}")  # Log the detailed dbt error
        raise

@flow
def elt_pipeline():
    trigger_airbyte_sync()
    run_dbt_via_subprocess()

# Run the flow
if __name__ == "__main__":
    elt_pipeline()
