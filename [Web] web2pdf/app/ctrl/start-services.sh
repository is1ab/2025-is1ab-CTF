#!/bin/sh
set -e

# replace dynamic flag
sed -i 's/flag{fake_flag}/'"$GZCTF_FLAG"'/' /flag
export GZCTF_FLAG=not_flag
GZCTF_FLAG=not_flag

# ensure nginx runtime dir exists
mkdir -p /run/nginx

# launch redis in background
cd /app/db/
redis-server /app/db/redis.conf &

# launch uwsgi in background
cd /app/web/
uwsgi --ini /app/web/uwsgi.ini &

# launch crond in background
cron &

# launch nginx in foreground (PID 1 process for Docker)
nginx -g "daemon off;" &

# cleanup files older than 15 minutes, every minute
while sleep 60; do
    find /app/web/pdfs -maxdepth 1 -mmin +15 -type f -exec rm -f {} +
done

