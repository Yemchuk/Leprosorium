#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require "sqlite3"

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		username TEXT
	)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id integer,
		username TEXT
	)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
	content = params[:content]
	username = params[:username]

	hh = {:username => 'Type your name', 
    :content => 'Type text',}

    @error = hh.select {|key,_| params[key] == ''}.values.join(', ')

    if @error != ''
      return erb :new
    end


	@db.execute 'insert into Posts(content, created_date, username) values(?, datetime(),?)', [content,username]

	redirect to '/'
end

get '/details/:post_id' do
	post_id = params[:post_id]
	
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]
	username = params[:username]

	hh = {:username => 'Type your name', 
    :content => 'Type text',}

    @error = hh.select {|key,_| params[key] == ''}.values.join(', ')

    if @error != ''
       	return redirect to('/details/' + post_id)
       	erb '<div class="alert alert-danger"><%=@error%></div>'
    end

	@db.execute 'insert into Comments
	(
		content, 
		created_date, 
		post_id,
		username
	) values
	(
		?, 
		datetime(),
		?,
		?
	)', [content, post_id, username]

	redirect to('/details/' + post_id)
end