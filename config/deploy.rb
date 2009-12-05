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
  
end

