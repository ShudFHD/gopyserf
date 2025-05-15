# Updated 5 Nodes Topology with Serf & Containerlab & K3s & Custom Scedhuler & Controller DaemonSet
The updated file will run everything mentioned in the heading,
- Custom Scheduler:
    - Makes scheduling decisions based on node resource data.
    - Pulls metrics from the "resource-api" container in the DaemonSet.
    - Metrics include CPU, memory, and PSI-based sellable cores.

- Controller DaemonSet:
    - Runs on every node.
    - Monitors node pressure and resource usage.
    - Writes node offers to: /tmp/resource_offer.json
    - Hosts a local HTTP API to expose resource state.

- Liqo :
    - Need to be updated. You will see the liqo trying to install via ceos5node.yaml file in each but some issue, not able to install yet need to change.

## For Starting run the below command mentioned and you will have a 5 containers running in a containerlab, with serf, k3s installed, custom scheduler pod and Daemonset. For testing the scheduler there is a test pod in the /tmp/ folder you can run it and check the logs of the custom scheduler pod.

# 5 Nodes Topology with Serf & Containerlab

This project sets up a 5-node network topology using [Containerlab](https://containerlab.dev), along with Serf agents for decentralized cluster membership and node communication. It's useful for experimenting with service discovery, failure detection, and distributed coordination in lab environments.

---

## 🗂️ Project Structure

- `ceso5node.yml` — Main Containerlab topology definition file.
- `clab-century/` — Contains node-specific configs, TLS materials, inventory, and logs.
- `setup_nodes.sh` — Orchestrates the setup of nodes.
- `ipaddressing.sh` — Assigns IP addresses to nodes.
- `serf_agents_start.sh` — Starts Serf agents.
- `serf_agents_joining.sh` — Manages the joining of nodes to the Serf cluster.
- `serf/` —  Contains Serf binary .
- `pytogoapi/` —  Web Server API for Python (custom implementation).

---

## 🚀 Getting Started

### Prerequisites

- Docker & Containerlab installed
- Bash or Linux shell
- Git (for cloning and version control)

### Setup Steps

```bash
# Step 1: Clone the repo
git clone https://github.com/anjumm/gopyserf.git

# Step 2: Deploy the topology
sudo containerlab deploy -t ceso5node.yml

# Step 3: Assign IPs
./ipaddressing.sh

# Step 4: Start Serf agents
./serf_agents_start.sh

# Step 5: Join nodes into the cluster
./serf_agents_joining.sh
