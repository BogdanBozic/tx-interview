FROM python:3.9.10-slim-buster
WORKDIR /app
COPY ./app /app
RUN useradd -ms /bin/bash damir-hehe
ENV PATH="/home/damir-hehe/.local/bin:${PATH}"
USER damir-hehe
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r  requirements.txt \
    && rm -rf /var/lib/apt/lists/*
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
