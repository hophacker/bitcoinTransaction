require 'sinatra/base'
require 'sinatra/main'
require 'mysql'

enable :inline_templates
set :views, File.dirname(__FILE__) + '/views'

get '/' do
	erb :index
end

get '/graph' do
  haml :graph
end

get '/data' do
  res = ""
  ender = "{"
  begin
     # connect to the MySQL server
     dbh = Mysql.real_connect("localhost", "root", "", "bitcoin")
     # get server version string and display it
  rescue Mysql::Error => e
     puts "Error code: #{e.errno}"
     puts "Error message: #{e.error}"
     puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  else
     if !params[:last].nil?
    	res = dbh.query("SELECT * FROM stat WHERE time >" + params[:last])
     elsif !params[:many].nil?
     	res = dbh.query("SELECT * FROM stat ORDER BY time DESC LIMIT "+params[:many])
     else
     	res = dbh.query("SELECT * FROM stat ORDER BY time DESC LIMIT 10")
     end
     res.each do |row|
     	ender = "#{ender}  \"#{row[1]}\":{\"total\":#{row[2]}, \"avg\":#{row[3]}, \"max\":#{row[4]}, \"min\":#{row[5]}, \"count\":#{row[6]}}, "
     end
     comma = ender.length - 1
     ender = ender[0,comma] + "}"
  ensure
     # disconnect from server
     dbh.close if dbh
  end
  return ender 
end
