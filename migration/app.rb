require 'webrick'
require 'mysql2'

# Configure the MySQL client
client = Mysql2::Client.new(
  host: 'db',  # Docker Compose service name
  username: 'root',
  password: 'password',
  database: 'mydatabase'
)

# Define the web server
server = WEBrick::HTTPServer.new(Port: 8080)

# Define a response for the root path "/"
server.mount_proc '/' do |req, res|
  # Query the database
  results = client.query('SELECT * FROM mytable')

  # Build the HTML response
  html = '<html><body><h1>Data from MySQL</h1><ul>'
  results.each do |row|
    html += "<li>#{row['name']}</li>"
  end
  html += '</ul></body></html>'

  res.body = html
end

# Trap interrupts (Ctrl+C) to gracefully shut down the server
trap 'INT' do
  server.shutdown
end

# Start the server
server.start

