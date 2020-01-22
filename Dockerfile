FROM python:3.7 AS builder

RUN pip install --no-cache-dir mlflow

CMD [ "mlflow", "server" ]
