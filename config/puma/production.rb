threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!
bind "tcp://0.0.0.0:%s" % ENV.fetch("RAILS_PORT") { 3000 }

# Require token for control app in production
if ENV['PUMA_CONTROL_APP_TOKEN'].present?
  activate_control_app 'tcp://0.0.0.0:%s' % ENV['PUMA_CONTROL_APP_PORT'],
                       { token: ENV['PUMA_CONTROL_APP_TOKEN'] }
end
