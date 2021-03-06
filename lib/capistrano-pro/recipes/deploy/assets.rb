Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :assets do
      desc <<-DESC
        Run the asset precompilation rake task. You can specify the full path \
        to the rake executable by setting the rake variable. You can also \
        specify additional environment variables to pass to rake via the \
        asset_env variable.
        Skips if there were no changes since last revision. 
        The defaults are:
    
          set :rake,      "rake"
          set :rails_env, "production"
          set :asset_env, "RAILS_GROUPS=assets"
      DESC
      task :precompile, :roles => :web, :except => { :no_release => true } do
        from = source.next_revision(current_revision)
        if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
          run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
        else
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
      end    
    end
  end
end
