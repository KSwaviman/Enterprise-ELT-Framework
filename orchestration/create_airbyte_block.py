from prefect_airbyte import AirbyteServer
from prefect.blocks.system import Secret

# Create a new Airbyte server block
airbyte_block = AirbyteServer(
    server_host="localhost",  # or your Airbyte instance URL
    server_port="8000",       # default Airbyte API port
    #api_token=Secret.load("airbyte-api-token")  # If using a token, otherwise leave empty
)
airbyte_block.save(name="my-airbyte-server")
