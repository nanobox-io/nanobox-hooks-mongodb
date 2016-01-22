
if payload[:member][:role] == "primary"
  execute "initiate replica set" do
    command <<-EOF
      echo 'rs.initiate({ _id : "gonano", \
      members : [ \
        {_id : 0, host : "#{payload[:generation][:members].select {|member| member[:role] == "primary"}[0][:local_ip]}:27017", priority: 1}, \
        {_id : 1, host : "#{payload[:generation][:members].select {|member| member[:role] == "secondary"}[0][:local_ip]}:27017", priority: 0.5}, \
        {_id : 2, host : "#{payload[:generation][:members].select {|member| member[:role] == "monitor"}[0][:local_ip]}", arbiterOnly: true} \
      ] })' | /data/bin/mongo
    EOF
    user 'gonano'
  end
end
