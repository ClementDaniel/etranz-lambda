# Dockerfile
FROM amazonlinux:2

# Install dependencies
RUN yum update -y && \
    yum install -y \
    docker \
    unzip \
    curl \
    git \
    aws-cli \
    && yum clean all

CMD ["bash"]
