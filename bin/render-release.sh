#!/usr/bin/env bash
set -o errexit

./bin/rails db:prepare

./bin/rails runner "
  conn = ActiveRecord::Base.connection
  unless conn.table_exists?('solid_queue_jobs')
    puts 'Loading solid_queue schema...'
    abort('solid_queue schema load failed') unless system(
      { 'DISABLE_DATABASE_ENVIRONMENT_CHECK' => '1' },
      'bin/rails', 'db:schema:load:queue'
    )
  end
  unless conn.table_exists?('solid_cache_entries')
    puts 'Loading solid_cache schema...'
    abort('solid_cache schema load failed') unless system(
      { 'DISABLE_DATABASE_ENVIRONMENT_CHECK' => '1' },
      'bin/rails', 'db:schema:load:cache'
    )
  end
  unless conn.table_exists?('solid_cable_messages')
    puts 'Loading solid_cable schema...'
    abort('solid_cable schema load failed') unless system(
      { 'DISABLE_DATABASE_ENVIRONMENT_CHECK' => '1' },
      'bin/rails', 'db:schema:load:cable'
    )
  end
  puts 'Solid schemas OK'
"
