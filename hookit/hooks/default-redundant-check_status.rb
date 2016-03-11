# config = execute "check replica set config" do
#   command <<-EOF
#     /data/bin/mongo --eval 'rs.config();'
#   EOF
# end

# status = execute "check replica set status" do
#   command <<-EOF
#     /data/bin/mongo --eval 'rs.status().shellPrint();'
#   EOF
# end

if payload[:member][:role] == "primary"
  begin
    # 2.x returns null if not initiated
    # 3.x exits poorly if not initiated
    config = execute "check replica set config" do
      command <<-EOF
        /data/bin/mongo --eval 'rs.config();'
      EOF
    end

    if config =~ /null/
      raise "config is null"
    end
  rescue
    execute "initialize replica set config" do
      command <<-EOF
        /data/bin/mongo --eval 'rs.initiate();'
      EOF
    end
  end

  config = execute "check replica set config" do
    command <<-EOF
      /data/bin/mongo --eval 'rs.config();'
    EOF
  end

  if config =~ /null/
    raise "config still null"
  end

  # raise "/data/bin/mongo --eval 'rs.reconfig({ _id : \"gonano\", members : [ {_id : 0, host : \"#{payload[:generation][:members].select {|member| member[:role] == "primary"}[0][:local_ip]}:27017\", priority: 1}, {_id : 1, host : \"#{payload[:generation][:members].select {|member| member[:role] == "secondary"}[0][:local_ip]}:27017\", priority: 0.5}, {_id : 2, host : \"#{payload[:generation][:members].select {|member| member[:role] == "monitor"}[0][:local_ip]}\", arbiterOnly: true} ] });'"

  execute "reconfig replica set" do
    command <<-EOF
      /data/bin/mongo --eval 'rs.reconfig({ _id : "gonano", members : [ {_id : 0, host : "#{payload[:generation][:members].select {|member| member[:role] == "primary"}[0][:local_ip]}:27017", priority: 1}, {_id : 1, host : "#{payload[:generation][:members].select {|member| member[:role] == "secondary"}[0][:local_ip]}:27017", priority: 0.5}, {_id : 2, host : "#{payload[:generation][:members].select {|member| member[:role] == "monitor"}[0][:local_ip]}", arbiterOnly: true} ] }, {force : true});'
    EOF
    user 'gonano'
  end
end

require 'timeout'

begin
  Timeout::timeout(90) do
    loop do
      status = execute "check replica set status" do
        command <<-EOF
          /data/bin/mongo --eval 'printjson(rs.status());'
        EOF
      end
      sleep 10
      break if status =~ /PRIMARY/ and status =~ /SECONDARY/ and status =~ /ARBITER/
    end
  end
rescue Timeout::Error
  exit 1
end

# config = execute "check replica set config" do
#   command <<-EOF
#     /data/bin/mongo --eval 'rs.config().shellPrint();'
#   EOF
# end

# status = execute "check replica set status" do
#   command <<-EOF
#     /data/bin/mongo --eval 'rs.status().shellPrint();'
#   EOF
# end
