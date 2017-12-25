KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_MASTER="--master=http://{% for host in groups['all'] %}{{ hostvars[host]['ansible_default_ipv4']['address'] }}{% endfor %}:8080"