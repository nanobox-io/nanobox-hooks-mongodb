
include Hooky::Mongodb

boxfile = converge( BOXFILE_DEFAULTS, payload[:boxfile] )

# config file
template "/data/etc/mongod.conf" do
  source 'mongodb-repl.conf.erb'
  mode 0644
  variables ({ boxfile: boxfile })
  owner 'gonano'
  group 'gonano'
end

# config and start db
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
