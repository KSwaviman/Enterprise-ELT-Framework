# Use Prefect's official Docker image with Python 3.10
FROM prefecthq/prefect:2.10.13-python3.10

# Set the working directory in the container
WORKDIR /app

# Copy your project files to the working directory
COPY . /app
# Copy your DBT profiles to the correct location
COPY dbt_config /root/.dbt


# Install system dependencies, including 'expect' for automation
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
    expect \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft's ODBC Driver 17 for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get install -y unixodbc-dev


# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install dbt and dbt-sqlserver adapter
RUN pip install --no-cache-dir 'dbt-core==1.8.5' 'dbt-sqlserver==1.8.2'

# Install prefect-dbt
RUN pip install --no-cache-dir 'prefect-dbt==0.2.0'

# Copy the Prefect profile configuration
RUN mkdir -p /root/.prefect
COPY profiles.toml /root/.prefect/profiles.toml

# Expose port 4200 for Prefect server
EXPOSE 4200

# Make the startup scripts executable
RUN chmod +x /app/start_prefect_server.expect /app/start_prefect_and_run_flow.sh

# Set environment variables
ENV PREFECT_PROFILE=default

# Set the default command to execute the startup script
CMD ["/app/start_prefect_and_run_flow.sh"]
