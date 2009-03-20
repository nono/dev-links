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
  @title = 'Les liens les plus populaires'
  @links = Link.popular
  haml :index
end

get '/links' do
  @title = 'Les liens les plus récents'
  @links = Link.all
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

get '/links/:link_id' do
  begin
    @link = Link.find(params[:link_id])
    haml :show
  rescue RecordNotFound
    redirect '/'
  end
end

get '/links/:link_id/plus' do
  begin
    @link = Link.find(params[:link_id])
    @link.score_plus
    redirect "/links/#{@link.id}"
  rescue RecordNotFound
    redirect '/'
  end
end

get '/links/:link_id/minus' do
  begin
    @link = Link.find(params[:link_id])
    @link.score_minus
    redirect "/links/#{@link.id}"
  rescue RecordNotFound
    redirect '/'
  end
end

