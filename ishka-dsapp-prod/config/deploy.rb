# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.11'

set :application, 'ishka_ds_app'
set :repo_url,  'git@github.com:pinak1180/ishka_ds_app.git'
set :deploy_to, '/var/www/applications/ishka_ds_app'

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails sidekiq sidekiqctl]
set :rbenv_roles, %i[app web sidekiq]
set :sidekiq_monit_conf_dir, '/etc/monit/conf.d'
set :sidekiq_monit_use_sudo, true
set :whenever_roles, ['whenever']

# Capistrano seems to assume shared dir under
# /var/www/ems - overiding default_shared path
set :shared_path, File.join(deploy_to, 'shared')

set :sidekiq_roles, [:sidekiq]

set :scm, :git
set :ssh_options, forward_agent: true, keepalive: true
set :log_level, :debug

SSHKit.config.command_map[:rake]  = 'bundle exec rake'
SSHKit.config.command_map[:rails] = 'bundle exec rails'
set :linked_files, %w[config/database.yml config/master.key]
set :linked_dirs, %w[
  log
  public/system
  tmp/cache
  tmp/pids
  tmp/sockets
  vendor/bundle
]

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :reindex do
    on roles(:sidekiq) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'chewy:deploy'
        end
      end
    end
  end

  after 'deploy:publishing', 'deploy:restart'
  after 'deploy:restart',    'deploy:reindex'
  after 'finishing',         'deploy:cleanup'
end
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
