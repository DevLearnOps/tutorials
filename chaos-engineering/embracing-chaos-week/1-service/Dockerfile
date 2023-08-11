FROM python:3.11-alpine

RUN pip3 install -U \
    uvicorn \
    requests \
    starlette \
    structlog

WORKDIR /app

COPY app.py .

EXPOSE 8000

CMD ["uvicorn", "--port", "8000", "--host", "0.0.0.0", "app:app"]
