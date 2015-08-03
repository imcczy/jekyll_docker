FROM ubuntu
MAINTAINER imcczy <imcczyh@gmail.com>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV OPENRESTY_VERSION 1.7.10.2
ENV RUBY_VERSION 2.2.1

RUN apt-get update && apt-get install -y supervisor  git curl nodejs \
    libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl wget && \
    apt-get clean

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
    && curl -L https://get.rvm.io | bash -s stable

RUN  /bin/bash -l -c "source /etc/profile.d/rvm.sh" &&  /bin/bash -l -c "rvm install ${RUBY_VERSION}" && \
     /bin/bash -l -c "rvm ${RUBY_VERSION} --default" &&  /bin/bash -l -c "gem install jekyll --no-rdoc --no-ri"

RUN wget http://openresty.org/download/ngx_openresty-${OPENRESTY_VERSION}.tar.gz && \
    tar -xzvf ngx_openresty-*.tar.gz && \
    rm -f ngx_openresty-*.tar.gz && \
    cd /ngx_openresty-${OPENRESTY_VERSION} && \
    cd bundle/LuaJIT-* && \
    make clean && make && make install && \
    ln -sf luajit-2.1.0-alpha /usr/local/bin/luajit && \
    cd /ngx_openresty-${OPENRESTY_VERSION} && \
    ./configure --prefix=/usr/servers --with-luajit && \
    make && make install && make clean && \
    cd / && \
    rm -rf ngx_openresty-*

RUN mkdir /usr/servers/conf && \
    rm /usr/servers/nginx/conf/nginx.conf

ADD nginx.conf /usr/servers/nginx/conf/nginx.conf
ADD jekyll.conf /usr/servers/conf/jekyll.conf
ADD jekyll.lua /usr/servers/conf/jekyll.lua
ADD build.sh /usr/servers/conf/build.sh

RUN chmod +x /usr/servers/conf/build.sh

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD supervisord -c /etc/supervisor/conf.d/supervisord.conf