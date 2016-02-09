
service 'db' do
  action :enable
  init :runit
end

# Wait for server to start
until File.exists?( "/tmp/mongodb-27017.sock" )
   sleep( 1 )
end

sleep( 5 )

ensure_socket 'db' do
  port '27017'
  action :listening
end
