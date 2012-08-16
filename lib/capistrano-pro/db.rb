Capistrano::Configuration.instance.load do
  namespace :db do
    desc "Uploads config/deploy/database-#{rails_env}.yml to :shared_path/config/database.yml"
    task :upload_config, :except => { :no_release => true }, :role => :app do
      run "mkdir -p #{shared_path}/config";
      upload("./config/deploy/database-#{rails_env}.yml", "#{shared_path}/config/database.yml")
    end
  
    desc "Create symlink :release_path/config/database.yml to :shared_path/config/database.yml"
    task :symlink_config, :except => { :no_release => true }, :role => :app do
      run "rm -rf #{release_path}/config/database.yml"
      run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end

  after "deploy:finalize_update", "db:symlink_config"
end
