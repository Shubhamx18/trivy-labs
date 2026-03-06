FROM python:3.10-slim

# Upgrade pip first to remove pip-level CVEs
RUN pip install --upgrade pip

# Install app dependencies
RUN pip install flask

COPY app.py .

CMD ["python", "app.py"]
