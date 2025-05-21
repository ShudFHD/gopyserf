from jinja2 import Environment, FileSystemLoader
import argparse

# Parse CLI arguments
parser = argparse.ArgumentParser(description="Generate containerlab topology YAML")
parser.add_argument("--nodes", type=int, default=5, help="Number of serf nodes to generate")
args = parser.parse_args()

# Load template
env = Environment(loader=FileSystemLoader("."))
template = env.get_template("topology_template.j2")

# Render template with dynamic node count
output = template.render(node_count=args.nodes)

# Save output to file
with open("century_clab.yaml", "w") as f:
    f.write(output)

print(f"Generated 'century_clab.yaml' with {args.nodes} serf nodes.")
