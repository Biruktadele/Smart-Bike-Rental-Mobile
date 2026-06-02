import json

def parse_node(node, indent=0):
    text = node.get("characters", "")
    type_ = node.get("type", "")
    name = node.get("name", "")
    
    prefix = "  " * indent
    if text:
        print(f"{prefix}- [{type_}] {name}: '{text}'")
    else:
        print(f"{prefix}- [{type_}] {name}")
        
    for child in node.get("children", []):
        parse_node(child, indent + 1)

try:
    with open('figma_node.json', 'r') as f:
        data = json.load(f)
        nodes = data.get("nodes", {})
        for k, v in nodes.items():
            doc = v.get("document", {})
            parse_node(doc)
except Exception as e:
    print(f"Error: {e}")
