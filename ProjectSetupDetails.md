
# Project Setup Details

This document provides an explanation of the key files and their roles in this project. The project is built with modern data engineering tools and utilizes Prefect for orchestration, Docker for containerization, and dbt for transformations.

## Key Files Overview

### 1. Dockerfile
The `Dockerfile` is responsible for setting up the Docker environment. It performs the following tasks:
- Sets the working directory for Docker.
- Copies project files into the Docker image.
- Installs necessary dependencies such as dbt, Prefect, and ODBC drivers.
- Configures environment variables and config files (e.g., profiles.toml for Prefect).
- Fires up the pipeline execution script `start_prefect_and_run_flow.sh`.

### 2. start_prefect_and_run_flow.sh
This shell script has two main aspects:
1. It starts the `start_prefect_server.expect` script to launch the Prefect server.
2. After a 90-seconds wait, it runs the `prefect_pipeline.py` file, which initiates the ELT pipeline process.

### 3. start_prefect_server.expect
The `start_prefect_server.expect` script automates the manual key inputs required to start the Prefect server. It simulates the following steps:
- Spawns the Prefect server.
- Simulates the down arrow and enter key commands when prompted to select the server mode (ephemeral or API).
- Enters the IP address for Docker to expose Prefect. The script passes `http://127.0.0.1:4200/api`, where Docker binds port 4200.
  
> **Note:** This address refers to the Docker container, not the local machine. If you wish to change the port, adjust this line in the script. Similarly if the port 8081 in your local machine is occupied make sure you use a different port binding and update the Docker run command accordingly.

With this setup, the Prefect server should start within 10-20 seconds.

### 4. Checking the Prefect Server
To ensure the Prefect server is running, navigate to `http://localhost:8081/` in your browser. Since port 8081 of the local machine is bound to Docker's 4200 port, you should be able to access the Prefect UI here if the server has started correctly.

### 5. prefect_pipeline.py
The `prefect_pipeline.py` file is executed as the second step in the `start_prefect_and_run_flow.sh` script. It orchestrates the ELT process as follows:
- Connects to the running Airbyte instance using the provided credentials.
- Fetches data from a specified API source.
- Loads the extracted data into the Google Cloud SQL database.
- Runs a dbt transformation to normalize the data using the models stored in the `transformation` directory (e.g., `products.sql`).

Refer to the comments in the `prefect_pipeline.py` file for a more detailed breakdown of the ELT process.

### 6. Google Cloud SQL and Data Access
Once the data is extracted and transformed, it is stored in Google Cloud SQL. You can view the final table either through the Google Cloud Console or by connecting with SQL Server Management Studio (SSMS) using the appropriate credentials.

### 7. SSAS Tabular Model and Power BI Visualization
- **SSAS (SQL Server Analysis Services)**: A tabular model is created in SSAS using the transformed SQL data. Custom DAX measures can be built for advanced analytics.
- **Power BI**: The SSAS cube is connected to Power BI to visualize the transformed data. Interactive reports and dashboards can be built based on the business needs.

Sample files for both the SSAS tabular model and Power BI reports are included in the project under the `SSAS` and `BI` directories, respectively.

## Final Considerations
This project provides a development version of the pipeline. Security measures, such as environment variables and Azure Key Vault, are not prioritized. Before deploying to production, ensure that security is properly managed.

For any questions or support, feel free to reach out to `info@swavimankumar.com`.

