# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# frozen_string_literal: true

set :output, 'log/cron_log.log'

every :day, at: (0..23).to_a.map { |x| (0..55).step(30).to_a.map { |a| ["#{x}:#{a}"] } }.flatten do
  rake 'daily_sync:sync_products_payload'
  rake 'daily_sync:sync_products_netsuite_details'
  rake 'daily_sync:sync_fulfillments'
end

every :day, at: (0..23).to_a.map { |x| (0..55).step(45).to_a.map { |a| ["#{x}:#{a}"] } }.flatten do
  #runner 'CommissionSyncJob.perform_later'
end

every :day, at: (0..23).to_a.map { |x| (0..55).step(60).to_a.map { |a| ["#{x}:#{a}"] } }.flatten do
  runner 'InventorySyncJob.perform_later'
end
