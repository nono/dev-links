#!/usr/bin/env ruby
# Author: Bruno Michel <bruno.michel@af83.com>
# Licence: MIT <http://www.opensource.org/licenses/mit-license.php>
#
# Copyright (c) 2009, AF83
# All rights reserved.

require 'rubygems'
require 'sinatra'

require 'models/link'

get '/' do
  @links = Link.popular
  haml :index
end

post '/links' do
  @link = Link.new
  @link.url = params[:url]
  @link.description = params[:description]
  if @link.save
    redirect '/'
  else
    haml :new
  end
end

get '/links/new' do
  @link = Link.new
  haml :new
end

