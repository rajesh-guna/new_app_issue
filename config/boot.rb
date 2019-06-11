# Set up gems listed in the Gemfile.

RAILS_ROOT = "#{File.dirname(__FILE__)}/" unless defined?(RAILS_ROOT)

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['DATABASE_URL'] = "mysql2://b1956486d577fa:649ec8f4@us-cdbr-iron-east-02.cleardb.net/heroku_40eddb2f5266297?reconnect=true"

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
