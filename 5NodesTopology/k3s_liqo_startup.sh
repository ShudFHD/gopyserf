#!/bin/bash
set -e

i=$1


if ! command -v k3s >/dev/null 2>&1; then
  apt-get update
  apt-get install -y curl python3 python3-pip
  curl -Lo /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/v1.32.4+k3s1/k3s
  chmod +x /usr/local/bin/k3s
  pip3 install flask requests kubernetes
fi

curl --fail -LS "https://github.com/liqotech/liqo/releases/download/v1.0.0/liqoctl-linux-amd64.tar.gz" | tar -xz
install -o root -g root -m 0755 liqoctl /usr/local/bin/liqoctl

while ! ip link show eth1 &> /dev/null; do
  echo "Waiting for eth1 to be created by Containerlab..."
  sleep 1
done

ip link set eth1 up
ip addr add 10.0.1.$((i + 10))/24 brd 10.0.1.255 dev eth1


while ! ip addr show dev eth1 | grep -q "inet 10.0.1.$((i + 10))/24"; do
  echo "Waiting for eth1 IP..."
  sleep 1
done

ip route del default || true
ip route add default via 10.0.1.1 dev eth1


while ! ip route | grep -q "^default via 10.0.1.1 dev eth1"; do
  echo "Waiting for default route..."
  sleep 1
done

ip link set eth1 mtu 1400

k3s server --node-name serf${i} --node-ip 10.0.1.$((i + 10)) --disable traefik --disable-network-policy --snapshotter native &
sleep 15

chmod 666 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


ip route del default via 10.0.1.1 dev eth1 || true
ip route add default via 172.20.20.1 dev eth0


while true; do
  running_pods=$(k3s kubectl get pods -n kube-system \
    -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{"\n"}{end}' |
    grep -E 'coredns|local-path-provisioner|metrics-server' |
    grep -c 'Running')

  if [ "$running_pods" -eq 3 ]; then
    echo "All required kube-system pods are running."
    break
  else
    echo "Waiting for kube-system pods... ($running_pods/3 ready)"
    sleep 5
  fi
done

liqoctl install k3s --kubeconfig /etc/rancher/k3s/k3s.yaml --cluster-id serf${i}

k3s kubectl apply -f /tmp/qos-controller-daemonset.yaml
k3s kubectl apply -f /tmp/service-account.yaml
k3s kubectl apply -f /tmp/cluster-role.yaml
k3s kubectl apply -f /tmp/cluster-role-binding.yaml
k3s kubectl apply -f /tmp/deployment-scheduler.yaml

mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chown $(whoami):$(whoami) ~/.kube/config
chmod 600 ~/.kube/config

sleep infinity
