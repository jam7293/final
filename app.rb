# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
require "geocoder"                                                                    #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

professors_table = DB.from(:professors)
feedback_table = DB.from(:feedback)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(users_id: session["user_id"]).to_a[0]
end

get "/" do
    #puts professors_table.all
    @professors = professors_table.all.to_a
    view "professors"
end

get "/professors/:id" do
    @professors = professors_table.where(id: params[:id]).to_a[0]
    @feedback = feedback_table.where(professors_id: @professors[:id])
    @users_table = users_table

    results = Geocoder.search(@professors[:address])
    intermediatestep = results.first.coordinates # => [lat, long]
    @lat_long = "#{intermediatestep[0]},#{intermediatestep[1]}"
    view "professor"
end

get "/professors/:id/feedback/new" do
    @professors = professors_table.where(id: params[:id]).to_a[0]
    view "new_feedback"
end

get "/professors/:id/feedback/create" do
    puts params
    @professors = professors_table.where(id: params["id"]).to_a[0]
    feedback_table.insert(professors_id: params["id"],
                       user_id: session["user_id"],
                       feedback: params["feedback"])
    view "create_feedback"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:users_id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end
