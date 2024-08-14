require 'webrick'
require 'mysql2'
require 'timeout'

# Method to check if the database is up and running
def wait_for_db(host:, username:, password:, database:, timeout: 60, interval: 5)
  start_time = Time.now

  while Time.now - start_time < timeout
    begin
      Timeout.timeout(interval) do
        client = Mysql2::Client.new(
          host: host,
          username: username,
          password: password,
          database: database
        )
        client.query('SELECT 1')  # Simple query to check connection
        client.close
        return true
      end
    rescue Mysql2::Error => e
      puts "Database connection failed: #{e.message}. Retrying..."
      sleep interval
    end
  end

  raise "Database did not become available within #{timeout} seconds."
end

# Wait for the MySQL database to be ready
wait_for_db(
  host: 'db',              # Docker Compose service name
  username: 'root',
  password: 'password',
  database: 'antcat'
)

# Configure the MySQL client
client = Mysql2::Client.new(
  host: 'db',
  username: 'root',
  password: 'password',
  database: 'antcat'
)

# Define the web server
server = WEBrick::HTTPServer.new(Port: 8080)

# Define a response for the root path "/"
server.mount_proc '/' do |req, res|
  # Query the database
  results = client.query('SELECT name FROM names LIMIT 100')

  # Build the HTML response
  html = '<html><body><h1>behold.....ANTS!</h1><ul>'
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

