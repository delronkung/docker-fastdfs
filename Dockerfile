FROM centos:7

MAINTAINER Delron Kung "delron.kung@gmail.com"

ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=

# install dependences
RUN yum install -y wget zlib zlib-devel pcre pcre-devel gcc gcc-c++ openssl openssl-devel libevent libevent-devel perl unzip net-tools git make

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs \
 && mkdir ${FASTDFS_BASE_PATH}

#compile the libfastcommon
WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN git clone --branch V1.0.36 --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/libfastcommon

#compile the fastdfs
WORKDIR ${FASTDFS_PATH}/fastdfs

RUN git clone --branch V5.11 --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs


EXPOSE 22122 23000 8080 8888
VOLUME ["$FASTDFS_BASE_PATH", "/etc/fdfs"]   

# download nginx
RUN mkdir -p /tmp/nginx && \
        wget "http://nginx.org/download/nginx-1.12.2.tar.gz" -P /tmp/nginx && \
        tar zxvf /tmp/nginx/nginx-1.12.2.tar.gz -C /tmp/nginx

# fastdfs-nginx-module
COPY fastdfs-nginx-module-master.zip /tmp/nginx/
RUN unzip /tmp/nginx/fastdfs-nginx-module-master.zip -d /tmp/nginx/
# install nginx
WORKDIR /tmp/nginx/nginx-1.12.2
RUN ./configure --prefix=/usr/local/nginx --add-module=/tmp/nginx/fastdfs-nginx-module-master/src && \
                         make && \
                         make install
        

COPY conf/*.* /etc/fdfs/
COPY nginx.conf /usr/local/nginx/conf/
COPY start1.sh /usr/bin/

RUN chmod 777 /usr/bin/start1.sh

ENTRYPOINT ["/usr/bin/start1.sh"]
CMD ["tracker"]

