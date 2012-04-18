require 'capistrano-pro/unicorn'

Capistrano::Configuration.instance.load do
  namespace :deploy do
    desc 'Start Unicorn (alias to unicorn:start)'
    task :start do
      unicorn.start
    end

    desc 'Stop Unicorn (alias to unicorn:stop)'
    task :stop do
      unicorn.stop
    end

    desc 'Restart Unicorn (alias to unicorn:restart)'
    task :restart do
      unicorn.restart
    end
  end
end
