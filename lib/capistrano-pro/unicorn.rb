Capistrano::Configuration.instance.load do
  # Set unicorn variables
  #
  _cset(:unicorn_pid, "#{fetch(:shared_path)}/pids/unicorn.pid")
  _cset(:unicorn_env, fetch(:rails_env, 'production'))
  _cset(:unicorn_bin, "unicorn")
  _cset(:unicorn_params, "-D")

  # Check if remote file exists
  #
  def remote_file_exists?(full_path)
    'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
  end

  # Check if process is running
  #
  def remote_process_exists?(pid_file)
    capture("ps -p $(cat #{pid_file}) ; true").strip.split("\n").size == 2
  end

  def resolve_unicorn_config_path
    config_paths = []
    config_paths << fetch(:unicorn_conf) unless fetch(:unicorn_conf, nil).nil?
    config_paths << "#{fetch(:current_path)}/config/unicorn.rb"
    config_paths << "#{fetch(:current_path)}/config/unicorn/#{unicorn_env}.rb"
    config_paths.each do |p|
      if remote_file_exists?(p)
        set :unicorn_conf, p
        return p
      end
    end
    logger.important("Config file for \"#{unicorn_env}\" environment was not found at \"#{config_paths.join(' or ')}\"", "Unicorn")
    return false
  end

  def unicorn_start
    logger.important("Starting...", "Unicorn")
    unicorn_exec = "bundle exec #{unicorn_bin}"
    unicorn_exec += " -c #{unicorn_conf}" if resolve_unicorn_config_path
    unicorn_exec += " -E #{unicorn_env} #{unicorn_params}"
    run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile #{unicorn_exec}"
  end

  namespace :unicorn do

    desc 'Start Unicorn'
    task :start, :roles => :app, :except => {:no_release => true} do
      if remote_file_exists?(unicorn_pid)
        if remote_process_exists?(unicorn_pid)
          logger.important("Unicorn is already running!", "Unicorn")
          next
        else
          run "rm #{unicorn_pid}"
        end
      end
      unicorn_start
    end

    desc 'Stop Unicorn'
    task :stop, :roles => :app, :except => {:no_release => true} do
      if remote_file_exists?(unicorn_pid)
        if remote_process_exists?(unicorn_pid)
          logger.important("Stopping...", "Unicorn")
          run "#{try_sudo} kill `cat #{unicorn_pid}`"
        else
          run "rm #{unicorn_pid}"
          logger.important("Unicorn is not running.", "Unicorn")
        end
      else
        logger.important("No PIDs found. Check if unicorn is running.", "Unicorn")
      end
    end

    desc 'Unicorn graceful shutdown'
    task :graceful, :roles => :app, :except => {:no_release => true} do
      if remote_file_exists?(unicorn_pid)
        if remote_process_exists?(unicorn_pid)
          logger.important("Stopping...", "Unicorn")
          run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
        else
          run "rm #{unicorn_pid}"
          logger.important("Unicorn is not running.", "Unicorn")
        end
      else
        logger.important("No PIDs found. Check if unicorn is running.", "Unicorn")
      end
    end

    desc 'Reload Unicorn'
    task :reload, :roles => :app, :except => {:no_release => true} do
      if remote_file_exists?(unicorn_pid) && remote_process_exists?(unicorn_pid)
        logger.important("Reloading...", "Unicorn")
        run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
      else
        logger.important("No PIDs found or process not exists.", "Unicorn")
        unicorn_start
      end
    end

    desc 'Restart Unicorn (alias for Reload Unicorn)'
    task :restart do
      unicorn.reload
    end
  end

end
