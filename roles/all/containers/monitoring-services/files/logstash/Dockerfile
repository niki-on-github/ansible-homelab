FROM docker.elastic.co/logstash/logstash:7.12.0
RUN bin/logstash-plugin install logstash-input-beats logstash-input-syslog logstash-output-elasticsearch logstash-filter-grok logstash-filter-geoip
