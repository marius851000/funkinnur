# Automatically perform some common patching on FNF code, of the "search and replace" kind

import sys
import os
import subprocess

if len(sys.argv) != 3:
    print("Not the right amount of argument gotten. Usage: {} <source folder> <dest folder>")
    raise BaseException("bad argument input")

REPLACEMENTS = [
    [
        "replay_path_save_content_1", # from vs-impostor kade engine
        "File.saveContent(\"assets/replays/",
        "File.saveContent(lime.system.System.applicationStorageDirectory + \"assets/replays/"
    ],
    [
        "replay_path_sys_get_cwd_1", # from vs impostor kade engine
        "Sys.getCwd() + 'assets/replays",
        "lime.system.System.applicationStorageDirectory + 'assets/replays"
    ],
    [
        "replay_path_sys_get_cwd_2", # from vs impostor kade engine
        "Sys.getCwd() + \"assets/replays",
        "lime.system.System.applicationStorageDirectory + \"assets/replays"
    ],
    [
        "replay_path_sys_get_cwd_3", # from vs impostor kade engine
        'Sys.getCwd() + "/assets/replays',
        'lime.system.System.applicationStorageDirectory + "/assets/replay'
    ],
    [
        "video_on_linux", # from psych-engine
        'name="VIDEOS_ALLOWED" if="web || windows"',
        'name="VIDEOS_ALLOWED" if="web || desktop"'
    ]
]

source_path = sys.argv[1]
dest_path = sys.argv[2]

os.makedirs(dest_path, exist_ok=True)

for path, dirs, files in os.walk(source_path):
    for file in files:
        source_file_path = os.path.join(path, file)
        dest_file_path = os.path.join(dest_path, os.path.relpath(path, source_path), file)
        os.makedirs(os.path.dirname(dest_file_path), exist_ok=True)
        print(source_file_path, dest_file_path)
        if file.endswith(".hx") or file.endswith(".xml"):
            try:
                f = open(source_file_path)
                t = f.read()
                f.close()
                for replacement in REPLACEMENTS:
                    t = t.replace(replacement[1], replacement[2])
                f = open(dest_file_path, "w")
                f.write(t)
                f.close()
            except UnicodeDecodeError as e:
                print(e)
        else:
            subprocess.check_call(["ln", "-s", source_file_path, dest_file_path])