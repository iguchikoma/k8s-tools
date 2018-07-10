#!/bin/bash
set -euvx

# Installs logrotate configuration files
function setup-logrotate() {
  mkdir -p /etc/logrotate.d/
  # Configure log rotation for all logs in /var/log, which is where k8s services
  # are configured to write their log files. Whenever logrotate is ran, this
  # config will:
  # * rotate the log file if its size is > 100Mb OR if one day has elapsed
  # * save rotated logs into a gzipped timestamped backup
  # * log file timestamp (controlled by 'dateformat') includes seconds too. This
  #   ensures that logrotate can generate unique logfiles during each rotation
  #   (otherwise it skips rotation if 'maxsize' is reached multiple times in a
  #   day).
  # * keep only 5 old (rotated) logs, and will discard older logs.
  cat > /etc/logrotate.d/allvarlogs <<EOF
/var/log/*.log {
    rotate ${LOGROTATE_FILES_MAX_COUNT:-5}
    copytruncate
    missingok
    notifempty
    compress
    maxsize ${LOGROTATE_MAX_SIZE:-100M}
    daily
    dateext
    dateformat -%Y%m%d-%s
    create 0644 root root
}
EOF

}

# Setup Docker loggging driver
function setup-docker-logging-driver() {
  cat > /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "1k", # Max size of the log files.
        "max-file": "5" # The maximum number of log files that can be present.
    }
}
EOF

}

########### Main Function ###########
function main() {
  echo "Start to configure instance for kubernetes log rotate"

  setup-logrotate
  setup-docker-logging-driver

  echo "Done for the configuration for kubernetes log rotate"
}

# use --source-only to test functions defined in this script.
if [[ "$#" -eq 1 && "${1}" == "--source-only" ]]; then
   :
else
   main "${@}"
fi

