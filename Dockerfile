# Sandbox test environment for GreatFET
FROM ubuntu:22.04
USER root

# Copy usb hub script from Jenkins' container
COPY --from=gsg-jenkins /startup/hubs.py /startup/hubs.py
COPY --from=gsg-jenkins /startup/.hubs /startup/.hubs
RUN ln -s /startup/hubs.py /usr/local/bin/hubs

# Override interactive installations and install prerequisite programs
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    gcc-arm-none-eabi \
    git \
    libusb-1.0-0-dev \
    python3 \
    python3-pip \
    python3-venv \
    python3-yaml \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install python-dotenv --upgrade

# Inform Docker that the container is listening on port 8080 at runtime
EXPOSE 8080
