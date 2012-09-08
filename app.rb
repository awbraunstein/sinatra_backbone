# -*- coding: utf-8 -*-
require 'sinatra'

require './db/db'

get '/' do
  redirect '/index.html'
end

Dir[File.dirname(__FILE__) + '/rest/*.rb'].each {|file| require file }
