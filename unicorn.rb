@dir = "/var/www/cw.wdidc.org/"
worker_processes 2
working_directory @dir
timeout 30
listen "#{@dir}tmp/sockets/unicorn.sock", backlog: 64
pid "#{@dir}tmp/pids/unicorn.pid"
