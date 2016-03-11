
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

# set mongodb config
directory '/data/var/db/mongodb' do
  owner 'gonano'
  group 'gonano'
end

directory '/var/log/mongodb' do
  owner 'gonano'
  group 'gonano'
end

directory '/data/var/run' do
  owner 'gonano'
  group 'gonano'
end

# create log file
file '/data/var/log/mongodb/mongodb.log' do
  owner 'gonano'
  group 'gonano'
end

# Configure narc
template '/opt/gonano/etc/narc.conf' do
  variables ({ uid: payload[:uid], app: payload[:app], logtap: payload[:logtap_host] })
end

directory '/etc/service/narc'

file '/etc/service/narc/run' do
  mode 0755
  content <<-EOF
#!/bin/sh -e
export PATH="/opt/local/sbin:/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gonano/sbin:/opt/gonano/bin"

exec /opt/gonano/bin/narcd /opt/gonano/etc/narc.conf
  EOF
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
