FROM python:3.9

WORKDIR /app

# install requirements
COPY requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt

# Expose port you want your app on
EXPOSE 8080

# Copy app code and set working directory
COPY . /app

# Run
ENTRYPOINT ["streamlit", "run", "app.py", "–server.port=8080", "–server.address=0.0.0.0"]