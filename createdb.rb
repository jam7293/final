# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :professors do
  primary_key :id
  String :title
  String :description, text: true
  String :quarter
  String :location
end
DB.create_table! :feedback do
  primary_key :feedback_id
  foreign_key :professor_id
  foreign_key :user_id
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :users_id
  Boolean :current_student
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
professors_table = DB.from(:professors)

professors_table.insert(title: "Professor Yay", 
                    description: "This guy is amazing and will teach you how to grow the heck our of your brand",
                    quarter: "Spring 2020",
                    location: "Evanston")

professors_table.insert(title: "Professor Nay", 
                    description: "This guy is a bore, but he'll show you how to build one hell of an Excel model...if that's your thing",
                    quarter: "Summer 2020",
                    location: "Chicago")
puts "Success"