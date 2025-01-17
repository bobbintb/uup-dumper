FROM ubuntu

RUN apt update && \
    apt -y install wget curl git aria2 cabextract wimtools chntpw genisoimage unzip libxml2-utils
COPY start.sh /

CMD ["/start.sh"]