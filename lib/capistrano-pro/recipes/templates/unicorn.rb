deploy_to = ""

timeout 30
worker_processes 4
#listen "#{deploy_to}/shared/unicorn.sock", :backlog => 1024

pid         "#{deploy_to}/shared/pids/unicorn.pid"
stdout_path "#{deploy_to}/shared/log/unicorn.log"
stderr_path "#{deploy_to}/shared/log/unicorn_error.log"

preload_app true

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection
end
