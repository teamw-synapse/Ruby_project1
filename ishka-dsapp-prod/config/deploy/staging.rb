# frozen_string_literal: true

set :stage, :production
set :branch, 'develop'
set :rails_env, 'staging'

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :db, %w[172.104.46.163], primary: true

server '172.104.46.163', user: 'admin', roles: %w[app web db sidekiq whenever]
