#!/bin/sh

### BEGIN INIT INFO
# Provides:             cphalod
# Required-Start:       $local_fs $remote_fs $network $named
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    CloudPassage Halo Agent
### END INIT INFO

. /lib/lsb/init-functions

CP='/var/vcap/packages/cp_halo'

start()
{
    status_of_proc -p $CP/data/halo.pid $CP/bin/cphalo cphalod > /dev/null
    if [ $? = 0 ]; then
      log_success_msg "The CloudPassage Halo Agent is already running"
      exit 0
    fi

    if [ ! -f "$CP/data/store.db.vector" ]; then
      if [ ! -f "$CP/data/cphalo.properties" ]; then
        log_failure_msg "Please run $CP/bin/configure"
        exit 1
      fi
      DAEMON_KEY=`grep "^daemon-key=[0-9a-f]*$" $CP/data/cphalo.properties`
      if [ "$DAEMON_KEY" = '' ] || [ `expr length "$DAEMON_KEY"` -ne 43 ]; then
        log_failure_msg "Please run $CP/bin/configure and specify your agent key"
        exit 1
      fi
    fi

    log_daemon_msg "Starting CloudPassage Halo Agent" "cphalo"

    if start-stop-daemon --start --quiet --oknodo --pidfile $CP/data/halo.pid --exec $CP/bin/cphalo -- --daemon --pidfile=$CP/data/halo.pid; then
      log_end_msg 0
    else
      log_end_msg 1
    fi

}

stop()
{
    log_daemon_msg "Stopping CloudPassage Halo Agent" "cphalo"
    if start-stop-daemon --stop --quiet --retry=TERM/5/KILL/5 --pidfile $CP/data/halo.pid --name cphalo; then
      start-stop-daemon --stop --quiet --retry=TERM/5/KILL/5 --name cphalow
      log_end_msg 0
    else
      log_end_msg 1
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
         status_of_proc -p $CP/data/halo.pid $CP/bin/cphalo cphalod && exit 0 || exit $?
        ;;
    restart|force-reload)
        start-stop-daemon --stop --quiet --retry=TERM/5/KILL/5 --pidfile $CP/data/halo.pid --name cphalo
        start-stop-daemon --stop --quiet --retry=TERM/5/KILL/5 --name cphalow
        start
        ;;
    *)
        echo "Usage: /etc/init.d/cphalod {start|stop|restart|status}"
        exit 1
esac

exit 0
