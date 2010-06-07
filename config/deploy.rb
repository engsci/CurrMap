default_run_options[:pty] = true

set :user, 'currmap'
set :domain, 'rafd.xen.prgmr.com'
set :application, "currmap"

role :app, "rafd.xen.prgmr.com"
role :web, "rafd.xen.prgmr.com"
role :db, "rafd.xen.prgmr.com", :primary => true

set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :ssh_options, { :forward_agent => true }

set :scm, "git"
set :repository,  "git@#{domain}:#{application}.git"
set :branch, "master"
set :git_enable_submodules, 1


namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/ferret #{release_path}/ferret"
    run "ln -nfs #{shared_path}/settings.yml #{release_path}/settings.yml"
  end
  
  desc "Update the CouchDB views to the newest version"
  task :update_couch_views do
    run "#{release_path}/views.rb"
  end
  
  desc "Copy settings.yaml over"
  task :update_settings do
    settings_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'settings.yml'))
    top.upload settings_file, "#{release_path}/settings.yml"
  end
  
end

after 'deploy:update_code', 'deploy:symlink_shared'
after 'deploy:update_code', 'deploy:update_couch_views'
after 'deploy:update_code', 'deploy:update_settings'