# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

# Start containers
@test "Start Old Containers" {
  start_container "simple-redundant-old-primary" "192.168.0.2"
  start_container "simple-redundant-old-secondary" "192.168.0.3"
  start_container "simple-redundant-old-monitor" "192.168.0.4"
}

@test "Start New Containers" {
  start_container "simple-redundant-new-primary" "192.168.0.6"
  start_container "simple-redundant-new-secondary" "192.168.0.7"
  start_container "simple-redundant-new-monitor" "192.168.0.8"
}

# Configure containers
@test "Configure Old Containers" {
  run run_hook "simple-redundant-old-primary" "default-configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-secondary" "default-configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-monitor" "monitor-configure" "$(payload monitor/configure)"
  echo_lines
  [ "$status" -eq 0 ]
}

# Configure containers
@test "Configure New Containers" {
  run run_hook "simple-redundant-new-primary" "default-configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-new-secondary" "default-configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-new-monitor" "monitor-configure" "$(payload monitor/configure)"
  echo_lines
  [ "$status" -eq 0 ]
  sleep 30
}

@test "Stop Old MongoDBs" {
  run run_hook "simple-redundant-old-primary" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-secondary" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Stop New MongoDBs" {
  run run_hook "simple-redundant-new-primary" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-new-secondary" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Redundant Configure Old Containers" {
  run run_hook "simple-redundant-old-primary" "default-redundant-configure" "$(payload default/redundant/configure-primary)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-secondary" "default-redundant-configure" "$(payload default/redundant/configure-secondary)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-monitor" "monitor-redundant-configure" "$(payload monitor/redundant/configure)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Redundant Configure New Containers" {
  run run_hook "simple-redundant-new-primary" "default-redundant-configure" "$(payload default/redundant/configure-primary-new)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-new-secondary" "default-redundant-configure" "$(payload default/redundant/configure-secondary-new)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-new-monitor" "monitor-redundant-configure" "$(payload monitor/redundant/configure-new)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Ensure Old MongoDBs Are Stopped" {
  while docker exec "simple-redundant-old-primary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  while docker exec "simple-redundant-old-secondary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

@test "Start Old MongoDB Cluster" {
  run run_hook "simple-redundant-old-primary" "default-start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-old-primary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  until docker exec "simple-redundant-old-primary" bash -c "nc 192.168.0.2 27017 < /dev/null"
  do
    sleep 1
  done
  run run_hook "simple-redundant-old-secondary" "default-start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-old-secondary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  until docker exec "simple-redundant-old-secondary" bash -c "nc 192.168.0.3 27017 < /dev/null"
  do
    sleep 1
  done
  run run_hook "simple-redundant-old-monitor" "monitor-start" "$(payload monitor/start)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-old-monitor" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

@test "Check Old MongoDB Status" {
  run run_hook "simple-redundant-old-primary" "default-redundant-check_status" "$(payload default/redundant/check_status-primary)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-secondary" "default-redundant-check_status" "$(payload default/redundant/check_status-secondary)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Ensure New MongoDBs Are Stopped" {
  while docker exec "simple-redundant-new-primary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  while docker exec "simple-redundant-new-secondary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

@test "Start New SSHD" {
  # start ssh server
  run run_hook "simple-redundant-new-primary" "default-start_sshd" "$(payload default/start_sshd)"
  echo_lines
  [ "$status" -eq 0 ]
  # start ssh server
  run run_hook "simple-redundant-new-secondary" "default-start_sshd" "$(payload default/start_sshd)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-new-primary" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
  until docker exec "simple-redundant-new-secondary" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
}

@test "Insert Old MongoDB Data" {
  run docker exec "simple-redundant-old-primary" bash -c "/data/bin/mongo --host gonano/192.168.0.2:27017,192.168.0.3:27017,192.168.0.4:27017 gonano --eval 'db.test.insert({\"key\": 1, \"value\": 1});'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "simple-redundant-old-primary" bash -c "/data/bin/mongo --host gonano/192.168.0.2:27017,192.168.0.3:27017,192.168.0.4:27017 gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[5]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "$status" -eq 0 ]
}

@test "Redundant Old Pre-Export" {
  run run_hook "simple-redundant-old-primary" "default-redundant-pre_export" "$(payload default/redundant/pre_export)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Insert Secondary MongoDB Data" {
  run docker exec "simple-redundant-old-secondary" bash -c "/data/bin/mongo --host gonano/192.168.0.2:27017,192.168.0.3:27017,192.168.0.4:27017 gonano --eval 'db.test.insert({\"key\": 2, \"value\": 2});'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "simple-redundant-old-secondary" bash -c "/data/bin/mongo --host gonano/192.168.0.2:27017,192.168.0.3:27017,192.168.0.4:27017 gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[5]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "${lines[6]}" = '{ "key" : 2, "value" : 2 }' ]
  [ "$status" -eq 0 ]
}

@test "Restop Old MongoDBs" {
  run run_hook "simple-redundant-old-primary" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-old-secondary" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Ensure Old MongoDBs Are Stopped" {
  while docker exec "simple-redundant-old-primary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  while docker exec "simple-redundant-old-secondary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

@test "Redundant Old Export" {
  run run_hook "simple-redundant-old-primary" "default-redundant-export" "$(payload default/redundant/export)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Stop New SSHD" {
  # stop ssh server
  run run_hook "simple-redundant-new-primary" "default-stop_sshd" "$(payload default/stop_sshd)"
  echo_lines
  [ "$status" -eq 0 ]
  # stop ssh server
  run run_hook "simple-redundant-new-secondary" "default-stop_sshd" "$(payload default/stop_sshd)"
  echo_lines
  [ "$status" -eq 0 ]
  while docker exec "simple-redundant-new-primary" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
  while docker exec "simple-redundant-new-secondary" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
}
@test "Start New MongoDB Cluster" {
  run run_hook "simple-redundant-new-primary" "default-start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-new-primary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  until docker exec "simple-redundant-new-primary" bash -c "nc 192.168.0.6 27017 < /dev/null"
  do
    sleep 1
  done
  run run_hook "simple-redundant-new-secondary" "default-start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-new-secondary" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  until docker exec "simple-redundant-new-secondary" bash -c "nc 192.168.0.7 27017 < /dev/null"
  do
    sleep 1
  done
  run run_hook "simple-redundant-new-monitor" "monitor-start" "$(payload monitor/start)"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-redundant-new-monitor" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

@test "Check New MongoDB Status" {
  run run_hook "simple-redundant-new-primary" "default-redundant-check_status" "$(payload default/redundant/check_status-primary-new)"
  echo_lines
  [ "$status" -eq 0 ]
  run run_hook "simple-redundant-new-secondary" "default-redundant-check_status" "$(payload default/redundant/check_status-secondary-new)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Verify New MongoDB Data" {
  run docker exec "simple-redundant-new-primary" bash -c "/data/bin/mongo --host gonano/192.168.0.6:27017,192.168.0.7:27017,192.168.0.8:27017 gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[5]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "${lines[6]}" = '{ "key" : 2, "value" : 2 }' ]
  [ "$status" -eq 0 ]
}

# Stop containers
@test "Stop Old Containers" {
  stop_container "simple-redundant-old-primary"
  stop_container "simple-redundant-old-secondary"
  stop_container "simple-redundant-old-monitor"
}

@test "Stop New Containers" {
  stop_container "simple-redundant-new-primary"
  stop_container "simple-redundant-new-secondary"
  stop_container "simple-redundant-new-monitor"
}