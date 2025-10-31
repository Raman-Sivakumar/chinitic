FROM amazonlinux:2

RUN yum install -y awscli tar gzip cronie docker-cli && yum clean all

WORKDIR /app
COPY backup.sh .
COPY aws-credentials.env .
RUN chmod +x backup.sh

CMD ["crond", "-f"]
