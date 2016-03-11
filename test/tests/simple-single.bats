# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Local Container" {
  start_container "simple-single-local" "192.168.0.2"
}

@test "Configure Local Container" {
  run run_hook "simple-single-local" "default-configure" "$(payload default/configure-local)"
  echo_lines
  [ "$status" -eq 0 ] 
}

@test "Start Local MongoDB" {
  run run_hook "simple-single-local" "default-start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-local bash -c "ps aux | grep [m]ongod"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-single-local" bash -c "nc 192.168.0.2 27017 < /dev/null"
  do
    sleep 1
  done
}

@test "Insert Local MongoDB Data" {
  run docker exec "simple-single-local" bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"key\": 1, \"value\": 1});'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "simple-single-local" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "$status" -eq 0 ]
}

@test "Stop Local MongoDB" {
  run run_hook "simple-single-local" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  while docker exec "simple-single-local" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-local bash -c "ps aux | grep [m]ongod"
  echo_lines
  [ "$status" -eq 1 ] 
}

@test "Stop Local Container" {
  stop_container "simple-single-local"
}

@test "Start Production Container" {
  start_container "simple-single-production" "192.168.0.2"
}

@test "Configure Production Container" {
  run run_hook "simple-single-production" "default-configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ] 
}

@test "Start Production MongoDB" {
  run run_hook "simple-single-production" "default-start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-production bash -c "ps aux | grep [m]ongod"
  echo_lines
  [ "$status" -eq 0 ]
  until docker exec "simple-single-production" bash -c "nc 192.168.0.2 27017 < /dev/null"
  do
    sleep 1
  done
}

@test "Insert Production MongoDB Data" {
  run docker exec "simple-single-production" bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"key\": 1, \"value\": 1})'"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec "simple-single-production" bash -c "/data/bin/mongo gonano --eval 'db.test.find({}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = '{ "key" : 1, "value" : 1 }' ]
  [ "$status" -eq 0 ]
}

@test "Stop Production MongoDB" {
  run run_hook "simple-single-production" "default-stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  while docker exec "simple-single-production" bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-production bash -c "ps aux | grep [m]ongod"
  echo_lines
  [ "$status" -eq 1 ] 
}

@test "Stop Production Container" {
  stop_container "simple-single-production"
}