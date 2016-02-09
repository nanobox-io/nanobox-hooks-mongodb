include Hooky::Mongodb

# Setup
boxfile = converge( BOXFILE_DEFAULTS, payload[:boxfile] )

directory '/data/var/db/mongodb' do
  recursive true
end

# chown data/var/db/mongodb for gonano
execute 'chown /data/var/db/mongodb' do
  command 'chown -R gonano:gonano /data/var/db/mongodb'
end

# create log file
file '/data/var/log/mongodb/mongodb.log' do
  owner 'gonano'
  group 'gonano'
end

directory '/data/var/run' do
  owner 'gonano'
  group 'gonano'
end

# set mongodb config
template '/data/etc/mongod.conf' do
  source 'mongodb.conf.erb'
  mode 0600
  owner 'gonano'
  group 'gonano'
  variables ({ boxfile: boxfile, user: "nanobox" })
end

# Import service (and start)
directory '/etc/service/db' do
  recursive true
end

directory '/etc/service/db/log' do
  recursive true
end

template '/etc/service/db/log/run' do
  mode 0755
  source 'log-run.erb'
  variables ({ svc: "db" })
end

template '/etc/service/db/run' do
  mode 0755
  variables ({ exec: "/data/bin/mongod --smallfiles --config /data/etc/mongod.conf 2>&1" })
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
