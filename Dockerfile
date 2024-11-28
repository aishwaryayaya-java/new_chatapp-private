# Use an official Ubuntu base image
FROM ubuntu:18.04

# Set environment variables to avoid interactive prompts during the installation
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variable to ensure Python output is not buffered
ENV PYTHONUNBUFFERED=1

# Update and install system dependencies including curl
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-pip \
    python3-venv \
    build-essential \
    libssl-dev \
    libffi-dev \
    libsodium-dev \
    libpython3-dev \
    default-libmysqlclient-dev \
    mysql-client-core-5.7 \
    curl \
    && apt-get clean

# Set the working directory in the container
WORKDIR /app

# Copy the entire project into the container
COPY . /app/

# Create and activate a virtual environment, then install Python dependencies
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install the required Python dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install -r requirements.txt

# Install mysqlclient for MySQL integration
RUN pip install mysqlclient

# Install Gunicorn (WSGI server for production)
RUN pip install gunicorn

# Set the working directory to the fundoo directory where manage.py is located
WORKDIR /app/fundoo

# Expose the port the app runs on
EXPOSE 8000

# Environment variables for database connection
ENV DB_NAME=chatapp
ENV DB_USER=aishwarya
ENV DB_PASSWORD=Aishdip@2002
ENV DB_HOST=db-container
ENV DB_PORT=3306

# Command to apply migrations and run the app with Gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn fundoo.wsgi:application --bind 0.0.0.0:8000"]
