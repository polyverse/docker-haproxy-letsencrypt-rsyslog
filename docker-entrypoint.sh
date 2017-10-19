#!/bin/sh

set -e

#Make the log file & change log file permission
touch /var/log/haproxy/haproxy.log
chmod 644 /var/log/haproxy/haproxy.log

# Make sure service is running
service rsyslog start

# Throw the log to output
tail -f /var/log/haproxy.log &

# Start haproxy
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg


### Work towards handling signals
pid=0

# SIGUSR1-handler
my_handler() {
  echo "my_handler"
}

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

# run application
node program &
pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
