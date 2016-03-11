
# pipe the backup into mongodb client to restore from backup
execute "restore from backup" do
  command <<-EOF
    bash -c 'ssh -o StrictHostKeyChecking=no #{payload[:backup][:local_ip]} \
    "cat /data/var/db/mongodb/#{payload[:backup][:backup_id]}.tgz" \
      | tar -C / -zxf -
    /data/bin/mongorestore --oplogReplay --drop /mongodump
    for i in ${PIPESTATUS[@]}; do
      if [[ $i -ne 0 ]]; then
        exit $i
      fi
    done
    '
  EOF
end
