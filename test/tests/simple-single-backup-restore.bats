# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Container" {
  start_container "backup-restore" "192.168.0.2"
  run run_hook "backup-restore" "default-configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ] 
  run run_hook "backup-restore" "default-start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec backup-restore bash -c "ps aux | grep [m]ongod"
  # [ "$status" -eq 0 ]
  until docker exec "backup-restore" bash -c "nc 192.168.0.2 27017 < /dev/null"
  do
    sleep 1
  done
}

@test "Start Backup Container" {
  start_container "backup" "192.168.0.3"
  # generate some keys
  run run_hook "backup" "default-configure" "$(payload default/configure-production)"
  [ "$status" -eq 0 ]

  # start ssh server
  run run_hook "backup" "default-start_sshd" "$(payload default/start_sshd)"
  [ "$status" -eq 0 ]
  until docker exec "backup" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
}

@test "Insert MongoDB Data" {
  run docker exec "backup-restore" bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"key\": 1, \"value\": 1});'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "backup-restore" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "$status" -eq 0 ]
}

@test "Backup" {
  run run_hook "backup-restore" "default-backup" "$(payload default/backup)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Update MongoDB Data" {
  run docker exec "backup-restore" bash -c "/data/bin/mongo gonano --eval 'db.test.update({\"key\": 1}, {\$set:{\"value\":2}})'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "backup-restore" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 2 }' ]
  [ "$status" -eq 0 ]
}

@test "Restore" {
  run run_hook "backup-restore" "default-restore" "$(payload default/restore)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Verify MongoDB Data" {
  run docker exec "backup-restore" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "$status" -eq 0 ]
}

@test "Stop Container" {
  stop_container "backup-restore"
}

@test "Stop Backup Container" {
  stop_container "backup"
}