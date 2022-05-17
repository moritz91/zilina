FROM python:3.8

WORKDIR /usr/app
ADD ./requirements.txt ./
RUN python -m pip install --upgrade pip && \
    pip install -r requirements.txt
COPY nltk_data ./nltk_data
COPY python ./python
CMD ["python", "-u", "python/classifier.py"]
