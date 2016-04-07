require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require_relative './env.rb'
include FileUtils::Verbose

get '/' do
  erb :index
end

post '/decks' do
  tempfile = params[:file][:tempfile]
  filename = params[:file][:filename]
  cp(tempfile.path, "public/uploads/#{filename}")
  @url = "#{request.base_url}/uploads/#{filename}"
  Pony.mail(
    :to => params[:instructor_email],
    :cc => params[:producer_email],
    :via => :smtp,
    :via_options => {
      :address => 'smtp.gmail.com',
      :port => '587',
      :enable_starttls_auto => true,
      :user_name => 'GA@generalassemb.ly',
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
  erb :thanks
end