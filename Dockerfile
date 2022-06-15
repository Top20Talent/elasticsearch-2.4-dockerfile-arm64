FROM alpine

CMD ["/bin/sh"]
ENV LANG=C.UTF-8

COPY docker-java-home /usr/local/bin/docker-java-home
RUN chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
ENV JAVA_VERSION=8u171
ENV JAVA_ALPINE_VERSION=8.322.06-r0
RUN set -x \
  && apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION"
RUN set -x [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN addgroup -S elasticsearch && adduser -S -G elasticsearch elasticsearch

RUN apk add --no-cache 'su-exec>=0.2' bash

ENV GPG_KEY=46095ACC8548582C1A2699A9D27D666CD88E42B4
WORKDIR /usr/share/elasticsearch
ENV PATH=/usr/share/elasticsearch/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
ENV ELASTICSEARCH_VERSION=2.4.6
ENV ELASTICSEARCH_TARBALL=https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.4.6.tar.gz ELASTICSEARCH_TARBALL_ASC=https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.4.6.tar.gz.asc ELASTICSEARCH_TARBALL_SHA1=c3441bef89cd91206edf3cf3bd5c4b62550e60a9

RUN set -ex; apk add --no-cache --virtual .fetch-deps 		ca-certificates 		gnupg 		openssl 		tar 	; 

RUN	wget -O elasticsearch.tar.gz "$ELASTICSEARCH_TARBALL"; 		

RUN if [ "$ELASTICSEARCH_TARBALL_SHA1" ]; then echo "$ELASTICSEARCH_TARBALL_SHA1 *elasticsearch.tar.gz" | sha1sum -c -; fi;

RUN if [ "$ELASTICSEARCH_TARBALL_ASC" ]; then wget -O elasticsearch.tar.gz.asc "$ELASTICSEARCH_TARBALL_ASC"; 		export GNUPGHOME="$(mktemp -d)"; gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; rm -rf "$GNUPGHOME" elasticsearch.tar.gz.asc; 	fi; 		
RUN tar -xf elasticsearch.tar.gz --strip-components=1; 	rm elasticsearch.tar.gz; 		
RUN apk del .fetch-deps; 		mkdir -p ./plugins; 	for path in 		./data 		./logs 		./config 		./config/scripts 	; do 		mkdir -p "$path"; 	chown -R elasticsearch:elasticsearch "$path"; 	done; 		
RUN export ES_JAVA_OPTS='-Xms32m -Xmx32m'; 	
RUN if [ "${ELASTICSEARCH_VERSION%%.*}" -gt 1 ]; then 		elasticsearch --version; 	else 		elasticsearch -v; 	fi

COPY ./config ./config
VOLUME [/usr/share/elasticsearch/data]
COPY  docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
EXPOSE 9200/tcp 9300/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]