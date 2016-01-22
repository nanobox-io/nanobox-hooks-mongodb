
include Hooky::Mongodb

boxfile = converge( BOXFILE_DEFAULTS, payload[:boxfile] )

# set mongodb.conf
template "/data/etc/mongodb/mongod.conf" do
  source 'mongodb-repl.conf.erb'
  mode 0644
  variables ({ boxfile: boxfile })
  owner 'gopagoda'
  group 'gopagoda'
end
