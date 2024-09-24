# Use Prefect's official Docker image with Python 3.10
FROM prefecthq/prefect:2.10.13-python3.10

# Set the working directory in the container
WORKDIR /app

# Copy your project files to the working directory
COPY . /app

# Copy the dbt profiles directory
COPY dbt_config /root/.dbt

# Copy the Prefect profile configuration
COPY profiles.toml /root/.prefect/profiles.toml

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unixodbc-dev \
    curl \
    gnupg2 \
    build-essential \
    libssl-dev \
    libpq-dev \
    libffi-dev \
    libnss3-dev \
    libsqlite3-dev \
    sqlite3 \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && rm -rf /var/lib/apt/lists/*

# Install dbt and dbt-sqlserver adapter
RUN pip install --no-cache-dir 'dbt-core==1.8.5' 'dbt-sqlserver==1.8.2'

# Install prefect-dbt
RUN pip install --no-cache-dir 'prefect-dbt==0.2.0'

# Install other dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# Expose port 4200 for Prefect server
EXPOSE 4200


# Make the startup script executable
RUN chmod +x /app/start_prefect_and_run_flow.sh

# Define the command to start Prefect server and run the flow
CMD ["/app/start_prefect_and_run_flow.sh"]
