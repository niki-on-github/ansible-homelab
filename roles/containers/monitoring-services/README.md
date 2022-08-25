# Monitoring Services

- **InfluxDB**: Open Source time series database written in Go.
- **Elasticsearch**: Open Source NoSQL database written in Java.
- **Logstash**: Server-side data processing pipeline that ingests data from a multitude of sources.
- **Kibana**: Data visualization dashboard for Elasticsearch.
- **Grafana**: Open Source analytics and interactive visualization web application with charts, graphs, and alerts.
- **Uptime Kuma**: self-hosted monitoring tool

## Default login

### Grafana

To use the authelia login you have to set the user email manually to `root@{{ domain }}` to be able to login with authelia. We can automate this as son as [#52336](https://github.com/grafana/grafana/issues/52336) is implemented.

## uptime-kuma

Add local docker service by docker-compose service name: e.g. `http://gitea:3000` for the gitea instance (if deployed in same docker network).
