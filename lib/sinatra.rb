require 'sinatra/base'
require 'sinatra/main'
require 'mysql'

enable :inline_templates

get '/' do
	erb :index
end

get '/data/' do
  res = ""
  begin
     # connect to the MySQL server
     dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")
     # get server version string and display it
  rescue Mysql::Error => e
     puts "Error code: #{e.errno}"
     puts "Error message: #{e.error}"
     puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  else
     if params[:last]?
    	res = dbh.query("SELECT * FROM bit WHERE time >" + params[:last])
     elsif params[:many]?
     	res = dbh.query("SELECT * FROM bit ORDER BY time DESC LIMIT "+params[:many])
     else
     	res = dbh.query("SELECT * FROM bit ORDER BY time DESC LIMIT 10")
     end
    puts res
  ensure
     # disconnect from server
     dbh.close if dbh
  end
end
