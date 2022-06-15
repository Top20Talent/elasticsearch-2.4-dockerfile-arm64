# Elasticsearch 2.4 Docker file
This Docker file is generated from [an old amd64 platform image](https://hub.docker.com/layers/elasticsearch/library/elasticsearch/2.4-alpine/images/sha256-26d1ac62cc2941c8a98bebc0916af3ee2954ebab305c80470e965ea16044b769?context=explore
), but it won't work for new arm64.

Then we created this docker file for new apple M1 machine.

## build
docker build -t tmp/elasticsearch:2.4-alpine .

## replace existing one
docker tag tmp/elasticsearch:2.4-alpine elasticsearch:2.4-alpine

then run your docker compose