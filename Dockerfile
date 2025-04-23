# Use official Python base image
FROM python:3.10-slim

# Set working directory in the container
WORKDIR /app

# Copy requirements and app files
COPY requirements.txt .
COPY incident_tracker.py .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port for Streamlit
EXPOSE 8501

# Run Streamlit app
CMD ["streamlit", "run", "incident_tracker.py", "--server.port=8501", "--server.enableCORS=false"]
