require 'sinatra'
require 'slim'
require 'mongo'
require 'json/ext' # required for .to_json

include Mongo

configure do
  # conn = MongoClient.new 'localhost', 27017
  # set :mongo_connection, conn
  # set :mongo_db, conn.db('blog')
  # posts_collection = mongo_db.collection('posts')
  set :mongo_db, MongoClient.new.db('blog')
end

# model
class Post
  @collection = Sinatra::Application.settings.mongo_db.collection('posts')

  def self.all
    @collection.find.sort created_at: :desc # cursor
  end

  def self.create(post)
    # content_type :json
    new_id = @collection.insert post.merge(created_at: Time.now)
    # id = object_id(id) if String === id
    @collection.find_one(_id: new_id)
  end
end

get '/' do
  @title = 'Welcome to My Blog'
  @posts = Post.all.limit 10
  slim :index
end

get '/posts/new' do
  slim :new
end

post '/posts' do
  @post = Post.create params
  if @post
    redirect '/'
  end # TODO
end
