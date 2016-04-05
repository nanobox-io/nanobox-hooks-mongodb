
service_name="MongoDB"
default_port=27017
multi_master="false"

wait_for_running() {
  container=$1
  until docker exec ${container} bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

wait_for_arbitrator_running() {
  container=$1
  until docker exec ${container} bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

wait_for_listening() {
  container=$1
  ip=$2
  port=$3
  until docker exec ${container} bash -c "nc ${ip} ${port} < /dev/null"
  do
    sleep 1
  done
}

wait_for_stop() {
  container=$1
  while docker exec ${container} bash -c "ps aux | grep [m]ongod"
  do
    sleep 1
  done
}

verify_stopped() {
  container=$1
  run docker exec ${container} bash -c "ps aux | grep [m]ongod"
  echo_lines
  [ "$status" -eq 1 ] 
}

insert_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  until docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"writable\": \"true\"});'"
  do
    sleep 10
  done
  docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.remove({\"writable\": \"true\"});'"
  run docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"key\": \"${key}\", \"value\": \"${data}\"});'"
  echo_lines
  [ "$status" -eq 0 ]

}

update_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  until docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"writable\": \"true\"});'"
  do
    sleep 10
  done
  docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.remove({\"writable\": \"true\"});'"
  run docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.update({\"key\": \"${key}\"}, {\$set:{\"value\":\"${data}\"}})'"
  echo_lines
  [ "$status" -eq 0 ]
}

verify_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  until docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.insert({\"writable\": \"true\"});'"
  do
    sleep 10
  done
  docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.remove({\"writable\": \"true\"});'"
  run docker exec ${container} bash -c "/data/bin/mongo gonano --eval 'db.test.find({\"key\": \"${key}\"}, { key: 1, value: 1, _id:0 }).shellPrint();'"
  echo_lines
  [ "${lines[2]}" = "{ \"key\" : \"${key}\", \"value\" : \"${data}\" }" ]
  [ "$status" -eq 0 ]
}

verify_plan() {
  [ "${lines[0]}"  = "{" ]
  [ "${lines[1]}"  = "  \"redundant\": false," ]
  [ "${lines[2]}"  = "  \"horizontal\": false," ]
  [ "${lines[3]}"  = "  \"users\": [" ]
  [ "${lines[4]}"  = "  ]," ]
  [ "${lines[5]}"  = "  \"ips\": [" ]
  [ "${lines[6]}"  = "    \"default\"" ]
  [ "${lines[7]}"  = "  ]," ]
  [ "${lines[8]}"  = "  \"port\": 27017," ]
  [ "${lines[9]}"  = "  \"behaviors\": [" ]
  [ "${lines[10]}" = "    \"migratable\"," ]
  [ "${lines[11]}" = "    \"backupable\"" ]
  [ "${lines[12]}" = "  ]" ]
  [ "${lines[13]}" = "}" ]
}