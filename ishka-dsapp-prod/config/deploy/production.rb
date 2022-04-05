# frozen_string_literal: true

set :stage, :production
set :branch, 'master'
set :rails_env, 'production'

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :db, %w[139.162.53.43], primary: true
role :sidekiq, %w[139.162.53.43]

server '139.162.48.91', user: 'admin', roles: %w[app web]
server '139.162.53.43', user: 'admin', roles: %w[db whenever sidekiq]
