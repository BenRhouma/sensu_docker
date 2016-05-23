from ubuntu:16.04

MAINTAINER "Ben Rhouma Zied" <benrhoumazied@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start. 
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d


#RUN echo "LOG_LEVEL=debug" >> /etc/default/sensu

RUN apt-get upgrade -y && apt-get update && apt-get install -y redis-server vim rabbitmq-server supervisor wget
RUN wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -  && echo "deb     http://repositories.sensuapp.org/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list

# install sensu
RUN apt-get update && apt-get install -y sensu uchiwa



RUN mkdir -p /etc/sensu/ssl
ADD sensu/ssl/client/key.pem /etc/sensu/ssl/key.pem
ADD sensu/ssl/client/cert.pem /etc/sensu/ssl/cert.pem
RUN chown sensu:sensu /etc/sensu -R

# configure redis 
RUN sed -i '/bind 127.0.0.1/c\bind 0.0.0.0' /etc/redis/redis.conf

# add supervisord to run automatically services at container's bootstrap
add     supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# RabbitMQ configurtion
RUN rabbitmq-plugins enable rabbitmq_management
ADD rabbitmq/rabbitmq.config /etc/rabbitmq/rabbitmq.config

RUN echo 'NODENAME=rabbit@localhost' >> /etc/rabbitmq/rabbitmq-env.conf

RUN mkdir -p /etc/rabbitmq/ssl
ADD rabbitmq/ssl/server/cacert.pem /etc/rabbitmq/ssl/cacert.pem
ADD rabbitmq/ssl/server/key.pem /etc/rabbitmq/ssl/key.pem
ADD rabbitmq/ssl/server/cert.pem /etc/rabbitmq/ssl/cert.pem
RUN chown rabbitmq:rabbitmq /var/run/rabbitmq
RUN chown rabbitmq:rabbitmq /var/log/rabbitmq
RUN chown rabbitmq:rabbitmq /etc/rabbitmq -R

#rabbitmq (add user)
RUN service rabbitmq-server start && su -c 'rabbitmqctl add_vhost /sensu &&  rabbitmqctl add_user sensu Vistaprint001 && rabbitmqctl set_user_tags sensu administrator &&rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"'  -s /bin/bash rabbitmq


ADD sensu/config.json /etc/sensu/config.json
ADD sensu/uchiwa.json /etc/sensu/uchiwa.json

RUN echo "LOG_LEVEL=debug" >> /etc/default/sensu

add     supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 6379 15672 5671 4567 3000

cmd     ["/usr/bin/supervisord", "-n"]
