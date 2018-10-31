FROM ubuntu:14.04

RUN apt-get update \
  && apt-get install -y python3-pip \
  && apt-get install -y nginx supervisor

COPY /flask/requirements.txt /tmp/requirements.txt
RUN pip3 install uwsgi Flask \
  && pip3 install -r /tmp/requirements.txt

ADD ./flask /flask
ADD ./config /config

COPY /flask/requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

WORKDIR /flask

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV DATABASE_URL sqlite:////config/app.db

RUN flask db upgrade

# CMD ["./setup.sh"]

RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
  && rm /etc/nginx/sites-enabled/default

RUN ln -s /config/nginx.conf /etc/nginx/sites-enabled/ \
  && ln -s /config/supervisor.conf /etc/supervisor/conf.d/

EXPOSE 80

CMD ["supervisord", "-n"]
