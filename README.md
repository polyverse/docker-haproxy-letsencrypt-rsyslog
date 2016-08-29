[![](https://images.microbadger.com/badges/version/rafpe/docker-haproxy-rsyslog.svg)](http://microbadger.com/#/images/rafpe/docker-haproxy-rsyslog "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/rafpe/docker-haproxy-rsyslog.svg)](http://microbadger.com/#/images/rafpe/docker-haproxy-rsyslog "Get your own commit badge on microbadger.com")


# HAproxy with rsyslog

This docker container provides highly efficient load balancer which is HAproxy however to enrich logging of details
it also provides syslog information. 

## Pulling image from docker hub 
At the moment the docker image contains only single tag - which is *latest* and points to **latest** from HAproxy repository.
```
docker pull rafpe/docker-haproxy-rsyslog
```
## Running container 
In order to run container (assuming you have an haproxy config file) you can just run the following 
```
docker run -d -P -v ${PWD}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg rafpe/docker-haproxy-rsyslog
```

This is of course only basic example since you will for sure need to adjust it to your requirements like ports/networks/volumes etc.




