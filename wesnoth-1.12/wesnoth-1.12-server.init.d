#! /bin/sh
### BEGIN INIT INFO
# Provides:          wesnoth-1.12-server
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     
# Default-Stop:      0 1 2 3 4 5 6
# Short-Description: Starts Wesnoth server (1.12)
# Description:       Starts the Wesnoth server (1.12) used for multiplayer games.
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/games/wesnothd-1.12
DAEMON_OPTS=
NAME=wesnoth-1.12-server
DESC="Wesnoth server (1.12)"
PIDFILE=/var/run/$NAME.pid

test -x $DAEMON || exit 5

. /lib/lsb/init-functions

# Include wesnothd defaults if available
if [ -f /etc/default/$NAME ] ; then
	. /etc/default/$NAME
fi

set -e

wesnoth_start() {
	start-stop-daemon --start --quiet --pidfile $PIDFILE --oknodo \
		--background --exec $DAEMON --make-pidfile --chuid nobody \
		-- $DAEMON_OPTS > /dev/null 2> /dev/null || return 1
	return 0
}

wesnoth_stop() {
	start-stop-daemon --stop --quiet --pidfile $PIDFILE \
		--oknodo --exec $DAEMON || return 1
	rm -f $PIDFILE
	return 0
}

wesnoth_reload() {
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE
}

case "$1" in
  start)
	log_daemon_msg "Starting $DESC" "$NAME"
	wesnoth_start
	log_end_msg $?
	;;
  stop)
	log_daemon_msg "Stopping $DESC" "$NAME"
	wesnoth_stop
	log_end_msg $?
	;;
  reload)
  	log_daemon_msg "Reloading $DESC" "$NAME"
  	wesnoth_reload
	log_end_msg $?
  	;;

  restart|force-reload)
	log_daemon_msg "Restarting $DESC" "$NAME"
	wesnoth_stop && sleep 1 && wesnoth_start
	log_end_msg $?
	;;
  status)
	if [ -s "$PIDFILE" ]; then
		if kill -0 `cat $PIDFILE` 2> /dev/null; then
			log_success_msg "Wesnoth server is running"
			exit 0
		else
			log_failure_msg "$PIDFILE exists but Wesnoth server is not running"
			exit 1
		fi
	else
		log_success_msg "Wesnoth server is not running."
		exit 3
	fi
	;;
  *)
	log_success_msg "Usage: $0 {start|stop|status|restart|force-reload}" >&2
	exit 2
	;;
esac

exit 0
