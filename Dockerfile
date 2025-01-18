FROM ubuntu

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt -y install wget curl git aria2 cabextract wimtools chntpw genisoimage unzip libxml2-utils bc xxhash python3
COPY start.sh /
COPY info_creator.sh /

CMD ["/start.sh"]
