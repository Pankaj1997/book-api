# Use the official Python slim image as the base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file first to cache dependencies
COPY requirements.txt .

# Install the dependencies
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set the environment variable for Python to not buffer stdout/stderr
ENV PYTHONUNBUFFERED=1

# Expose the port (optional, specify the port your app runs on, e.g., 5000)
EXPOSE 5000

# Define the command to run the application
CMD ["python", "app.py"]

