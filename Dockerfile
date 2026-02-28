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

# Install USB hub PPPS dependencies
RUN pip3 install numpy python-dotenv git+https://github.com/CapableRobot/CapableRobot_USBHub_Driver --upgrade
RUN curl -L https://github.com/mvp/uhubctl/archive/refs/tags/v2.5.0.tar.gz > uhubctl-2.5.0.tar.gz \
    && mkdir uhubctl-2.5.0 \
    && tar -xvzf uhubctl-2.5.0.tar.gz -C uhubctl-2.5.0 --strip-components 1 \
    && rm uhubctl-2.5.0.tar.gz \
    && cd uhubctl-2.5.0 \
    && make \
    && make install

# Inform Docker that the container is listening on port 8080 at runtime
EXPOSE 8080
