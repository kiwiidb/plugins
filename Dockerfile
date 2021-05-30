FROM kiwiidb/lightningd

ARG EXTRA_PLUGINS='--recurse-submodules=csvexportpays \
--recurse-submodules=graphql \
--recurse-submodules=jwt-factory \
--recurse-submodules=python-teos \
--recurse-submodules=trustedcoin \
--recurse-submodules=sparko \
--recurse-submodules=webhook'

RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3-wheel python3-dev python3-venv libleveldb-dev pkg-config libc-bin git libpq-dev postgresql wget

COPY . /tmp/plugins
RUN mkdir -p /opt/lightningd/plugins/ && \
    cd /opt/lightningd/plugins && \
    git clone --depth 1 --shallow-submodules -j4 \
        ${EXTRA_PLUGINS} \
        file:///tmp/plugins . && \
    wget https://github.com/fiatjaf/trustedcoin/releases/download/v0.4.0/trustedcoin_linux_amd64 && \
    wget https://github.com/fiatjaf/sparko/releases/download/v2.5/sparko_linux_amd64 && \
    wget https://raw.githubusercontent.com/BoltzExchange/channel-creation-plugin/master/channel-creation.py && \
    chmod +x channel-creation.py && \
    chmod +x rebalance/rebalance.py && \
    chmod +x trustedcoin_linux_amd64 && \
    chmod +x sparko_linux_amd64 && \
    pip3 install setuptools && \
    pip3 install requests ecdsa && \
    find -name requirements.txt -exec pip3 install -r {} \;

EXPOSE 9735 9835
ENTRYPOINT  [ "/usr/bin/tini", "-g", "--", "./entrypoint.sh" ]
