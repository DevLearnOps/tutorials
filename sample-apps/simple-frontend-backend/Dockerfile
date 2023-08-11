FROM python:3.11-alpine

RUN pip3 install -U \
    uvicorn \
    requests \
    starlette \
    structlog

WORKDIR /app

ARG APP_MODULE
RUN { \
    echo "#!/bin/sh"; \
    echo "exec uvicorn --port 8000 --host 0.0.0.0 ${APP_MODULE}:app"; \
    } > run.sh \
    && chmod +x *.sh

COPY . .

EXPOSE 8000

CMD ["./run.sh"]
