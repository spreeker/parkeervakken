FROM amsterdam/python
MAINTAINER datapunt@amsterdam.nl

ENV PYTHONUNBUFFERED 1

EXPOSE 8000

RUN     adduser --system datapunt && \
	mkdir -p /static && \
	mkdir -p /data && \
	mkdir -p /unzipped && \
	chown datapunt /static && \
	chown datapunt /data && \
	chown datapunt /unzipped


COPY src /app/
COPY deploy /deploy/
COPY requirements.txt /app/

WORKDIR /app


RUN pip install --no-cache-dir -r requirements.txt


USER datapunt

RUN export DJANGO_SETTINGS_MODULE=parkeervakken_api.settings

CMD uwsgi

