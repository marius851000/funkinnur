import sys
import json
import os
import xml.etree.ElementTree as ET

if len(sys.argv) != 4:
    print("Usage: {} <funkin mod source tree> <human-written config file> <completed target json file>".format(sys.argv[0]))
    raise BaseException("No args provided")

source_tree_path = sys.argv[1]
source_json_path = sys.argv[2]
dest_json_path = sys.argv[3]

f = open(source_json_path)
working_json = json.load(f)
f.close()

# correct path
if "subfolder" in working_json:
    source_tree_path = os.path.join(source_tree_path, working_json["subfolder"])

# assume the type is sourcemod for now
if "type" not in working_json:
    working_json["type"] = "sourcemod"

if working_json["type"] == "sourcemod":
    if "built_binary_name" not in working_json or "name" not in working_json:
        project_path = os.path.join(source_tree_path, "Project.xml")
        project_project = ET.parse(project_path).getroot()
        project_app = project_project.find("app")
        if "built_binary_name" not in working_json:
            working_json["built_binary_name"] = project_app.attrib["file"]
        if "name" not in working_json:
            working_json["name"] = project_app.attrib["title"]
elif working_json["type"] == "psych-engine":
    if "name" not in working_json:
        path_to_pack = os.path.join(source_tree_path, "pack.json")
        f = open(path_to_pack)
        pack_data = json.load(f)
        f.close()
        working_json["name"] = pack_data["name"]
else:
    print("unrecognized mod kind: {}".format(working_json["type"]))


f = open(dest_json_path, "w")
json.dump(working_json, f, indent="\t")
f.close()