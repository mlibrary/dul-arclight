threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
environment ENV.fetch("RAILS_ENV") { "development" }
bind "tcp://0.0.0.0:%s" % ENV.fetch("RAILS_PORT") { 3000 }
plugin :tmp_restart
