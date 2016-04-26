require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'bitly'
require 'pry'

require_relative './env.rb'
include FileUtils::Verbose

Bitly.use_api_version_3

Bitly.configure do |config|
  config.api_version = 3
  config.access_token = TOKEN
end

get '/' do
  @coreid = params[:coreid]
  erb :index
end

post '/decks' do
  tempfile = params[:file][:tempfile]
  filename = params[:file][:filename]
  cp(tempfile.path, "public/uploads/#{filename}")
  chmod 0644, "public/uploads/#{filename}"
  @coreid = params[:coreid]
  @url = "#{request.base_url}/uploads/#{filename}"
  begin
    @url = Bitly.client.shorten(@url).short_url
  rescue
  end
  Pony.mail(
    :to => params[:instructor_email],
    :cc => params[:producer_email],
    :via => :smtp,
    :via_options => {
      :address => 'smtp.gmail.com',
      :port => '587',
      :enable_starttls_auto => true,
      :user_name => 'gadccw@gmail.com',
      :password => PASSWORD,
      :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain => "HELO", # don't know exactly what should be here
    },
    :subject => 'Class & Workshop Deck',
    :body => erb(:thanks),
    :headers => {
      'Content-Type' => 'text/html'
    }
  )
  Pony.mail(
    :to => 'claires@ga.co',
    :via => :smtp,
    :via_options => {
      :address => 'smtp.gmail.com',
      :port => '587',
      :enable_starttls_auto => true,
      :user_name => 'gadccw@gmail.com',
      :password => PASSWORD,
      :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain => "HELO", # don't know exactly what should be here
    },
    :subject => 'Class & Workshop Deck',
    :body => erb(:admin),
    :headers => {
      'Content-Type' => 'text/html'
    }
  )
  erb :thanks
end
