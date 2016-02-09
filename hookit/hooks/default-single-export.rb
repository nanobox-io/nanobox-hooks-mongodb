
execute "send diff data to new member" do
  command "rsync --delete -a /data/var/db/mongodb/. #{payload[:new_member][:local_ip]}:/data/var/db/mongodb/"
end
