FROM python:3.8.2-slim

WORKDIR /app

COPY Pipfile /app
COPY Pipfile.lock /app

RUN pip install pipenv \
  && pipenv install --deploy --system

COPY . /app

WORKDIR /app

ENTRYPOINT ["python"]
CMD ["app.py"]
