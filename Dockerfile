# This Dockerfile has been created based on the following work by Justin Ouellette:
# https://github.com/jstn/docker-unifi-video/blob/master/Dockerfile (0e8dbcc)

# Trusty
FROM phusion/baseimage:0.9.18

ENV DEBIAN_FRONTEND noninteractive

# Bring in the latest and greatest
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

RUN curl -sS http://dl.ubnt.com/firmwares/unifi-video/3.4.0/unifi-video_3.4.0~Ubuntu14.04_amd64.deb > /tmp/unifi-video.deb

# Install unifi-video dependencies and the core package itself
RUN apt-get install -y mongodb-server openjdk-7-jre-headless jsvc
RUN dpkg -i /tmp/unifi-video.deb && rm /tmp/unifi-video.deb
RUN apt-get update && apt-get -f install

RUN sed -i -e 's/^log/#log/' /etc/mongodb.conf
RUN printf "syslog = true" | tee -a /etc/mongodb.conf

RUN mkdir /etc/service/mongodb /etc/service/unifi-video
RUN printf "#!/bin/sh\nexec /sbin/setuser mongodb /usr/bin/mongod --config /etc/mongodb.conf" | tee /etc/service/mongodb/run
RUN printf "#!/bin/sh\nexec /usr/sbin/unifi-video --nodetach start" | tee /etc/service/unifi-video/run
RUN chmod 500 /etc/service/mongodb/run /etc/service/unifi-video/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Interfaces to outside
VOLUME ["/var/lib/mongodb", "/var/lib/unifi-video", "/var/log/unifi-video"]
EXPOSE 6666 7080 7443

CMD ["/sbin/my_init"]

# Make sure you have created the target directories:
#
# 1. /usr/local/unifi-video/unifi-video
# 2. /usr/local/unifi-video/mongodb
# 3. /usr/local/unifi-video/log
#
# Run container by:
# docker run -d --privileged \
# -v /usr/local/unifi-video/mongodb:/var/lib/mongodb \
# -v /usr/local/unifi-video/unifi-video:/var/lib/unifi-video \
# -v /usr/local/unifi-video/log:/var/log/unifi-video \
# -p 127.0.0.1:6666:6666 \
# -p 127.0.0.1:7080:7080 \
# -p 127.0.0.1:7443:7443 \
# exsilium/unifi-video:v3.4.0
