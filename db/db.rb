# -*- coding: utf-8 -*-
require 'data_mapper'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/sinatra_app_development")

Dir[File.dirname(__FILE__) + '/migrations/*.rb'].each {|file| require file }

DataMapper.finalize
DataMapper.auto_migrate!
