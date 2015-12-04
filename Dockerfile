# VERSION 1.1
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow
# SOURCE: https://github.com/puckel/docker-airflow

FROM ubuntu:trusty
MAINTAINER Puckel_

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
# Work around initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No
ENV AIRFLOW_VERSION 1.6.1
ENV AIRFLOW_HOME /usr/local/airflow
ENV PYTHONLIBPATH /usr/lib/python2.7/dist-packages

# Add airflow user
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow

RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
    netcat \
    curl

# Upgrade python -- Taken from http://tecadmin.net/install-python-2-7-on-ubuntu-and-linuxmint/#
RUN apt-get purge -y python.*
RUN apt-get install -yqq --no-install-recommends \
    build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
RUN curl -k -O https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
RUN tar xzf Python-2.7.10.tgz
RUN cd Python-2.7.10 && ./configure && make install && cd .. && rm -rf Python-2.7.10

RUN apt-get install -yqq --no-install-recommends \
    python-pip \
    python-dev \
    libmysqlclient-dev \
    libkrb5-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    build-essential \
    libpq-dev \
    python-psycopg2 \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" cryptography \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" airflow==${AIRFLOW_VERSION} \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" airflow[celery]==${AIRFLOW_VERSION} \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" airflow[mysql]==${AIRFLOW_VERSION} \
    && pip install --install-option="--install-purelib=$PYTHONLIBPATH" airflow[postgres]==${AIRFLOW_VERSION} \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

ADD script/entrypoint.sh ${AIRFLOW_HOME}/entrypoint.sh
ADD config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN \
    chown -R airflow: ${AIRFLOW_HOME} \
    && chmod +x ${AIRFLOW_HOME}/entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["./entrypoint.sh"]