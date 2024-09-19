import requests
from prefect import flow, task
from prefect_dbt.cli.commands import DbtCoreOperation
from requests.auth import HTTPBasicAuth

@task
def trigger_airbyte_sync():
    airbyte_url = "http://localhost:8000/api/v1/connections/sync"  # Adjust if your Airbyte is hosted elsewhere
    connection_id = "faeebcd1-a142-4815-aa01-5fdb4c84a779"
    
    # Airbyte default credentials or your custom credentials
    username = "airbyte"  # Replace with your Airbyte username
    password = "password"  # Replace with your Airbyte password
    
    # Trigger Airbyte sync via API with Basic Authentication
    response = requests.post(airbyte_url, json={"connectionId": connection_id}, auth=HTTPBasicAuth(username, password))
    
    if response.status_code == 200:
        print("Airbyte sync triggered successfully")
    else:
        print(f"Failed to trigger Airbyte sync: {response.status_code}, {response.text}")
        response.raise_for_status()

@task
def run_dbt_transformation():
    dbt_run = DbtCoreOperation(
        commands=["dbt run"],
        project_dir="D:/ELTv2",  # Path to your dbt project folder
        profiles_dir="C:/Users/kumar/.dbt",  # Directory containing profiles.yml
    )
    dbt_run.run()


@flow
def elt_pipeline():
    airbyte_sync = trigger_airbyte_sync()
    dbt_transform = run_dbt_transformation()

# Run the flow
if __name__ == "__main__":
    elt_pipeline()
