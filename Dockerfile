FROM phusion/baseimage:0.9.16
MAINTAINER Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update &&\
    apt-get install -y -q build-essential make &&\
    apt-get install -y -q openssl libssl-dev unixodbc-dev libncurses5-dev &&\
    apt-get install -y -q libexpat1-dev curl zile vim-nox git bash bash-completion &&\
    apt-get autoremove -y --purge &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV KERL_URL "https://raw.githubusercontent.com/yrashk/kerl/4e7c4349ddcd46ac11cd4cd50bfbda25f1f11ca2/kerl"

RUN curl -O -s ${KERL_URL} &&\
    chmod a+x kerl &&\
    mv kerl /usr/bin

COPY kerlrc /root/.kerlrc

ENV OTP_VERSION "18.1"

RUN kerl update releases &&\
    kerl build ${OTP_VERSION} ${OTP_VERSION} &&\
    kerl install ${OTP_VERSION} /opt/erlang/${OTP_VERSION}

## Works for bash.
RUN echo ". /opt/erlang/${OTP_VERSION}/activate" >> /etc/bash.bashrc
## Might work for other shells.
#RUN echo ". /opt/erlang/${OTP_VERSION}/activate" >> /etc/profile
#RUN echo ". /opt/erlang/${OTP_VERSION}/activate" >> /etc/environment

## Unless we set TERM to something sensible (not necessarily xterm)
## the erlang shell is broken.
ENV TERM xterm

CMD ["/sbin/my_init"]
