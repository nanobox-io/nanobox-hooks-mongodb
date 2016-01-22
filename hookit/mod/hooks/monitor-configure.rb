
include Hooky::Mongodb

# Setup
boxfile = converge( BOXFILE_DEFAULTS, payload[:boxfile] )

# set mongodb config
directory '/data/etc/mongodb' do
  owner 'gonano'
  group 'gonano'
end

template "/data/etc/mongodb/mongodb.conf" do
  source 'mongodb-repl.conf.erb'
  mode 0644
  variables ({ boxfile: boxfile })
  owner 'gonano'
  group 'gonano'
end

# chown data/var/db/mongodb for gonano
execute "chown /data/var/db/mongodb" do
  command 'chown -R gonano:gonano /data/var/db/mongodb'
end

directory '/var/log/mongodb' do
  owner 'gonano'
  group 'gonano'
end

file '/var/log/mongodb/mongodb.log' do
  owner 'gonano'
  group 'gonano'
end

# Narc Setup
template '/opt/local/etc/narc/narc.conf' do
  variables ({
    service: payload[:service],
    app: payload[:app]
  })
end

if payload[:platform] != 'local'

  # Setup root keys for data migrations
  directory '/root/.ssh' do
    recursive true
  end

  file '/root/.ssh/id_rsa' do
    content payload[:ssh][:admin_key][:private_key]
    mode 0600
  end

  file '/root/.ssh/id_rsa.pub' do
    content payload[:ssh][:admin_key][:public_key]
  end

  file '/root/.ssh/authorized_keys' do
    content payload[:ssh][:admin_key][:public_key]
  end

end
