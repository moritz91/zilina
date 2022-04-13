FROM python:3.8

ENV HTTPS_PROXY=http://cias.geoaws.com:8080
ENV https_proxy=http://cias.geoaws.com:8080

WORKDIR /app

ADD ./requirements.txt ./
RUN pip install -r requirements.txt

ADD ./ ./
CMD ["python3", "-u","twitter_api.py"]
