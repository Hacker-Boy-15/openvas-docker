# OpenVAS
# Based on: http://hackertarget.com/install-openvas-7-ubuntu/
#
# VERSION       1.0.0

FROM phusion/baseimage
MAINTAINER Mike Splain mike.splain@gmail.com

RUN apt-get update -y
RUN apt-get install build-essential bison flex cmake pkg-config libglib2.0-dev libgnutls-dev libpcap0.8-dev libgpgme11 libgpgme11-dev doxygen libuuid1 uuid-dev sqlfairy xmltoman sqlite3 libsqlite3-dev libsqlite3-tcl libxml2-dev libxslt1.1 libxslt1-dev xsltproc libmicrohttpd-dev wget rsync -y

RUN mkdir openvas-src && \
    cd openvas-src/ && \
    wget http://wald.intevation.org/frs/download.php/1866/openvas-libraries-8.0+beta5.tar.gz && \
    wget http://wald.intevation.org/frs/download.php/1870/openvas-scanner-5.0+beta5.tar.gz && \
    wget http://wald.intevation.org/frs/download.php/1874/openvas-manager-6.0+beta5.tar.gz && \
    wget http://wald.intevation.org/frs/download.php/1878/greenbone-security-assistant-6.0+beta5.tar.gz && \
    wget http://wald.intevation.org/frs/download.php/1882/openvas-cli-1.4+beta5.tar.gz

RUN cd openvas-src/ && \
    tar zxvf openvas-libraries-8.0+beta5.tar.gz && \
    tar zxvf openvas-scanner-5.0+beta5.tar.gz && \
    tar zxvf openvas-manager-6.0+beta5.tar.gz && \
    tar zxvf greenbone-security-assistant-6.0+beta5.tar.gz && \
    tar zxvf openvas-cli-1.4+beta5.tar.gz

RUN cd openvas-src/openvas-libraries-8.0+beta5 && \
    mkdir source && \
    cd source && \
    cmake .. && \
    make && \
    make install

RUN cd openvas-src/openvas-scanner-5.0+beta5 && \
    mkdir source && \
    cd source && \
    cmake .. && \
    make && \
    make install

RUN cd openvas-src/openvas-manager-6.0+beta5 && \
    mkdir source && \
    cd source && \
    cmake .. && \
    make && \
    make install

RUN cd openvas-src/greenbone-security-assistant-6.0+beta5 && \
    mkdir source && \
    cd source && \
    cmake .. && \
    make && \
    make install

RUN cd openvas-src/openvas-cli-1.4+beta5 && \
    mkdir source && \
    cd source && \
    cmake .. && \
    make && \
    make install

RUN openvas-mkcert -q
RUN ldconfig
RUN openvassd && \
    openvas-nvt-sync && \
    openvas-scapdata-sync && \
    openvas-certdata-sync && \
    openvas-mkcert-client -n -i && \
    openvasmd --rebuild --progress && \
    openvasmd --create-user=admin --role=Admin && \
    openvasmd --user=admin --new-password=openvas

# Expose UI
EXPOSE 443

# Scanner ports
EXPOSE 9390
EXPOSE 9391

RUN mkdir /etc/service/gsad && \
    cd /etc/service/gsad && \
    wget -O run https://raw.githubusercontent.com/mikesplain/openvas-docker/master/bin/gsad && \
    chmod 700 run
RUN mkdir /etc/service/openvassd && \
    cd /etc/service/openvassd && \
    wget -O run https://raw.githubusercontent.com/mikesplain/openvas-docker/master/bin/openvassd && \
    chmod 700 run
RUN mkdir /etc/service/openvasmd && \
    cd /etc/service/openvasmd && \
    wget -O run https://raw.githubusercontent.com/mikesplain/openvas-docker/master/bin/openvasmd && \
    chmod 700 run
