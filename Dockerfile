FROM centos
LABEL maintainer="Michel Oosterhof <michel@oosterhof.net>"

ENV IBGW_USER=ibgw
ENV IBGW_GROUP=ibgw

# This sets up IB Gateway 978 (latest).
# The version of the JVM must be exactly 1.8.0_152.

# add ibgw:ibgw user
RUN groupadd -r ${IBGW_GROUP} \
    && useradd -r -m -g ${IBGW_GROUP} ${IBGW_USER}

RUN yum install -y unzip Xvfb which xauth libXrender libXtst lsof

# =============================================================================
# Install Java
# =============================================================================

# ENV JAVA_HOME /opt/jdk1.8.0_181
# COPY server-jre-8u181-linux-x64.tar.gz /tmp
# RUN tar xvfz /tmp/server-jre-8u181-linux-x64.tar.gz -C /opt && \
#     chown -R root:root $JAVA_HOME && \
#     chmod -R a+rX $JAVA_HOME && \
#     rm -f /tmp/server-jre-8u181-linux-x64.tar.gz
RUN alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 200000 && \
    alternatives --install /usr/bin/javaws javaws $JAVA_HOME/bin/javaws 200000 && \
    alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 200000

# =============================================================================
# Setup IB TWS
# =============================================================================

# ENV IBGATEWAYVERSION=stable
ENV IBGATEWAYVERSION=latest

WORKDIR /tmp
# RUN curl -O https://download2.interactivebrokers.com/installers/ibgateway/${IBGATEWAYVERSION}-standalone/${IBGATEWAYVERSION}-standalone-linux-x64.sh
COPY ibgateway-${IBGATEWAYVERSION}-standalone-linux-x64.sh /tmp
RUN chmod u+x /tmp/ibgateway-${IBGATEWAYVERSION}-standalone-linux-x64.sh
RUN echo 'n' | /tmp/ibgateway-${IBGATEWAYVERSION}-standalone-linux-x64.sh
RUN rm -f /tmp/ibgateway-${IBGATEWAYVERSION}-standalone-linux-x64.sh

# =============================================================================
# Setup IBC
# =============================================================================
ENV IBC_PATH=/opt/ibc
ENV IBC_VERSION=3.8.2
RUN mkdir -p $IBC_PATH /root/ibc
WORKDIR $IBC_PATH
# RUN curl -LO https://github.com/IbcAlpha/IBC/releases/download/${IBC_VERSION}/IBCLinux-${IBC_VERSION}.zip
COPY IBCLinux-${IBC_VERSION}.zip $IBC_PATH
RUN unzip ./IBCLinux-${IBC_VERSION}.zip
RUN find ${IBC_PATH} -name '*.sh' -print0 | xargs -0 chmod u+x
RUN rm -f IBCLinux-${IBC_VERSION}.zip
COPY config.ini /root/ibc

WORKDIR /
# =============================================================================
# Launch a virtual screen
# =============================================================================
ENV DISPLAY=:1

COPY start.sh ${IBC_PATH}
RUN chmod u+x ${IBC_PATH}/start.sh

COPY jts.ini /root/Jts/jts.ini

CMD tail --retry -f /root/Jts/launcher.log & xvfb-run /opt/ibc/start.sh -inline

# 7496 for live, 7497 for paper trading
EXPOSE 4000
