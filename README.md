[![](https://images.microbadger.com/badges/version/rafpe/docker-haproxy-rsyslog.svg)](http://microbadger.com/#/images/rafpe/docker-haproxy-rsyslog "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/rafpe/docker-haproxy-rsyslog.svg)](http://microbadger.com/#/images/rafpe/docker-haproxy-rsyslog "Get your own commit badge on microbadger.com")


# HAproxy with rsyslog and Let's Encrypt

This docker container provides highly efficient load balancer which is HAproxy combined with Let's Encrypt, and uses rsyslog to log to console (so you can get `kubectl logs` or `docker logs`.) 

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

Example configuration from [Play With Polyverse](https://github.com/polyverse/play-with-polyverse/blob/master/haproxy/haproxy.cfg)

```
global
    maxconn 256
    
    ### BEGIN: Let's Encrypt static blob
    lua-load /usr/local/etc/haproxy/acme-http01-webroot.lua
    chroot /jail
    ssl-default-bind-ciphers AES256+EECDH:AES256+EDH:!aNULL;
    tune.ssl.default-dh-param 4096
    ### END: Let's Encrypt static blob
    
    ### BEGIN: Send logs to rsyslog local (they'll just show up on console)
    log 127.0.0.1 local2 debug
    ### END: Send logs to rsyslog local (they'll just show up on console)
    
    log-send-hostname

defaults
    mode http
    log global
    option  httplog
    option logasap
    log-format %Ci:%Cp\ [%t]\ %ft\ %b/%s\ %Tq/%Tw/%Tc/%Tr/%Tt\ %st\ %B\ %cc\ %cs\ %tsc\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq\ %hr\ %hs\ %{+Q}r\ %[src]
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option forwardfor
    option http-server-close


frontend http-in
    bind *:80

    ### BEGIN: Generate let's encrypt cert for incoming host
    capture request header Host len 1024
    acl url_acme_http01 path_beg /.well-known/acme-challenge/
    http-request use-service lua.acme-http01 if METH_GET url_acme_http01
    ### END: Generate let's encrypt cert for incoming host

    ### BEGIN: Redirect all traffic to https
    redirect scheme https code 301 if !{ ssl_fc } !host_direct 
    ### BEGIN:  Redirect all traffic to https


    acl host_direct hdr_reg(host) -i ^.*\.direct\..*$
    use_backend l2 if host_direct

    default_backend pwd 

frontend ft_ssl_vip
    bind *:443 ssl crt /usr/local/etc/haproxy/certs/ no-sslv3 no-tls-tickets no-tlsv10 no-tlsv11

    capture request header Host len 1024
    http-request set-header X-Forwarded-Proto https

    rspadd Strict-Transport-Security:\ max-age=15768000

    default_backend pwd

backend pwd
    server node1 pwd:3000

backend l2
    server node2 l2:443

```




