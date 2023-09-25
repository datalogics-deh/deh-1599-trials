import json

with open("cdk.json") as cdk_json:
    cdk_json_data = json.load(cdk_json)

# Exclude PDM projects and all Python caches from 'cdk watch'
cdk_json_data["watch"]["exclude"].extend(
    ["pyproject.toml", "pdm.lock", "**/__pycache__"]
)

with open("cdk.json", "w") as cdk_json:
    json.dump(cdk_json_data, cdk_json, indent=2)
