FROM python:3.7

RUN pip install --no-cache-dir mlflow

CMD [ "mlflow", "server" ]
