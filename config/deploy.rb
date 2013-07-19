require 'bundler/capistrano'

set :rails_env, ENV['RAILS_ENV'] || "unstable"
set :application, ENV['HOST'] || 'riyosha.vagrant.vm'

set :deploy_to, "/var/www/#{application}"
role :web, "#{application}"
role :app, "#{application}"
role :db,  "#{application}", :primary => true

default_run_options[:pty] = true

ssh_options[:forward_agent] = false
set :user, "capistrano"
set :use_sudo, false
set :copy_exclude, %w(.git spec)

if fetch(:application).end_with?('vagrant.vm')
  set :scm, :none
  set :repository, '.'
  set :deploy_via, :copy
  set :copy_strategy, :export
  ssh_options[:keys] = [ENV['IDENTITY'] || './vagrant/puppet-applications/'\
    'vagrant-modules/vagrant_capistrano_id_dsa']
else
  set :deploy_via, :remote_cache
  set :scm, :git
  set :scm_username, ENV['CAP_USER']
  set :repository, ENV['SCM']

  if variables.include?(:branch_name)
    set :branch, "#{branch_name}"
  else
    set :branch, "master"
  end
  set :git_enable_submodules, 1
end

before "deploy:assets:precompile", "config:symlink"
after "deploy:update", "deploy:cleanup"

def link_config_file(name)
  run "ln -nfs #{deploy_to}/shared/config/#{name} "\
    "#{release_path}/config/#{name}"
end

namespace :config do
  desc "linking configuration to current release"
  task :symlink do
    link_config_file('database.yml')
    link_config_file('initializers/devisecas.local.rb')
    link_config_file('initializers/secret_token.local.rb')
    link_config_file('initializers/dtuauth.local.rb')
  end
end

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
