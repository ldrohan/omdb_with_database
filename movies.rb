require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  #Add code here
erb :index
end


#Add code here
get '/results' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  @movies = c.exec_params("select * from movie WHERE title = $1;",[params["title"]])
  c.close
  erb :results
end


get '/movie/:id' do
#sections 3 and 4
c = PGconn.new(:host => "localhost", :dbname => dbname)
  @movie = c.exec_params("select * from movie WHERE id = $1;",[params["id"]])
  c.close
erb :show
end

get'/movies/new' do
erb :new
end

post '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  c.exec_params("INSERT INTO movie (title, year) VALUES ($1, $2);",
                  [params["title"], params["year"]])
  c.close
  redirect '/'
  
end

def dbname
  "movie"
end

def create_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec "DROP TABLE movie;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movie (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

