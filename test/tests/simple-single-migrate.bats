# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Old Container" {
  start_container "simple-single-old" "192.168.0.2"
}

@test "Configure Old Container" {
  run run_hook "simple-single-old" "default-configure" "$(payload default/configure-production)"

  [ "$status" -eq 0 ] 
}

@test "Start Old MongoDB" {
  run run_hook "simple-single-old" "default-start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-old bash -c "ps aux | grep [m]ongod"
  [ "$status" -eq 0 ]
  until docker exec "simple-single-old" bash -c "nc 192.168.0.2 27017 < /dev/null"
  do
    sleep 1
  done
}

@test "Insert Old MongoDB Data" {
  run docker exec "simple-single-old" bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"key\": 1, \"value\": 1});'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "simple-single-old" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "$status" -eq 0 ]
}

@test "Start New Container" {
  start_container "simple-single-new" "192.168.0.3"
}

@test "Configure New Container" {
  run run_hook "simple-single-new" "default-configure" "$(payload default/configure-production)"
  [ "$status" -eq 0 ] 
}

@test "Start New MongoDB" {
  run run_hook "simple-single-new" "default-start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-new bash -c "ps aux | grep [m]ongod"
  [ "$status" -eq 0 ] 
}

@test "Stop New MongoDB" {
  run run_hook "simple-single-new" "default-stop" "$(payload default/stop)"
  [ "$status" -eq 0 ]
  while docker exec "simple-single-new" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-new bash -c "ps aux | grep [m]ongod"
  [ "$status" -eq 1 ] 
}

@test "Start New SSHD" {
  # start ssh server
  run run_hook "simple-single-new" "default-start_sshd" "$(payload default/start_sshd)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-single-new" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
}

@test "Pre-Export Old MongoDB" {
  run run_hook "simple-single-old" "default-single-pre_export" "$(payload default/single/pre_export)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Update Old MongoDB Data" {
  run docker exec "simple-single-old" bash -c "/data/bin/mongo gonano --eval 'db.test.update({\"key\": 1}, {\$set:{\"value\":2}});'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "simple-single-old" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 2 }' ]
  [ "$status" -eq 0 ]
}

@test "Stop Old MongoDB" {
  run run_hook "simple-single-old" "default-stop" "$(payload default/stop)"
  [ "$status" -eq 0 ]
  while docker exec "simple-single-old" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-old bash -c "ps aux | grep [m]ongod"
  [ "$status" -eq 1 ] 
}

@test "Export Old MongoDB" {
  run run_hook "simple-single-old" "default-single-export" "$(payload default/single/export)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Stop New SSHD" {
  # stop ssh server
  run run_hook "simple-single-new" "default-stop_sshd" "$(payload default/stop_sshd)"
  [ "$status" -eq 0 ]
  while docker exec "simple-single-new" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
}

@test "Restart New MongoDB" {
  run run_hook "simple-single-new" "default-start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-new bash -c "ps aux | grep [m]ongod"
  [ "$status" -eq 0 ]
  until docker exec "simple-single-new" bash -c "nc 192.168.0.3 27017 < /dev/null"
  do
    sleep 1
  done
}

@test "Verify New MongoDB Data" {
  run docker exec "simple-single-new" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 2 }' ]
  [ "$status" -eq 0 ]
}

@test "Stop Old Container" {
  stop_container "simple-single-old"
}

@test "Stop New Container" {
  stop_container "simple-single-new"
}