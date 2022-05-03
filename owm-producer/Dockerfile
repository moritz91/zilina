FROM python:3.8.5

WORKDIR /usr/app

COPY ./requirements.txt ./
RUN pip install -r requirements.txt
COPY ./ ./

CMD ["python3", "-u", "openweathermap_producer.py"]
