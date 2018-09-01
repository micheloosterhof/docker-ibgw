FROM centos
MAINTAINER Michel Oosterhof <michel@oosterhof.net>

ENV IBGW_USER=ibgw
ENV IBGW_GROUP=ibgw

# This sets up IB Gateway 973 (latest).
# The version of the JVM must be exactly 1.8.0_152.

# add ibgw:ibgw user
RUN groupadd -r ${IBGW_GROUP} \
    && useradd -r -m -g ${IBGW_GROUP} ${IBGW_USER}

RUN yum install -y unzip Xvfb which xauth libXrender libXtst

# =============================================================================
# Install Java
# =============================================================================

ENV JAVA_HOME /opt/jdk1.8.0_181
COPY server-jre-8u181-linux-x64.tar.gz /tmp
RUN tar xvfz /tmp/server-jre-8u181-linux-x64.tar.gz -C /opt && \
    chown -R root:root $JAVA_HOME && \
    chmod -R a+rX $JAVA_HOME && \
    rm -f /tmp/server-jre-8u181-linux-x64.tar.gz
RUN alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 200000 && \
    alternatives --install /usr/bin/javaws javaws $JAVA_HOME/bin/javaws 200000 && \
    alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 200000

# =============================================================================
# Setup IB TWS
# =============================================================================
RUN mkdir -p /opt/TWS
WORKDIR /tmp
# RUN curl -O https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN curl -O https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
#COPY ibgateway-stable-standalone-linux-x64.sh /tmp
RUN chmod u+x /tmp/ibgateway-latest-standalone-linux-x64.sh
RUN echo 'n' | /tmp/ibgateway-latest-standalone-linux-x64.sh
RUN rm -f /tmp/ibgateway-latest-standalone-linux-x64.sh

# =============================================================================
# Setup IBC
# =============================================================================
ENV IBC_PATH=/opt/ibc
RUN mkdir -p $IBC_PATH /root/ibc
WORKDIR $IBC_PATH
RUN curl -LO https://github.com/IbcAlpha/IBC/releases/download/3.6.0/IBCLinux-3.6.0.zip
RUN unzip ./IBCLinux-3.6.0.zip
RUN find ${IBC_PATH} -name '*.sh' | xargs chmod u+x
RUN rm -f IBCLinux-3.6.0.zip
COPY config.ini /root/ibc

WORKDIR /
# =============================================================================
# Launch a virtual screen
# =============================================================================
ENV DISPLAY=:1

COPY start.sh ${IBC_PATH}
RUN chmod u+x ${IBC_PATH}/start.sh

CMD Xvfb :1 -screen 0 1024x768x24 & /opt/ibc/start.sh 

EXPOSE 4002
