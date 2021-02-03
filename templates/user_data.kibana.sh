#!/bin/bash

cat <<'EOF' >>/etc/kibana/kibana.yml
xpack.security.enabled: ${security_enabled}
xpack.monitoring.enabled: ${monitoring_enabled}
EOF

echo "elasticsearch.hosts:" | sudo tee -a /etc/kibana/kibana.yml
for i in $(seq -f "%06g" 0 $((${datas_count}-1))); do
    echo "- http://default-data$i:9200" | sudo tee -a /etc/kibana/kibana.yml
done

systemctl daemon-reload
systemctl enable kibana.service
sudo service kibana restart
