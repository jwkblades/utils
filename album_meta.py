#!/usr/bin/python

import glob
import json
import os
import subprocess

def readMetadataFile():
    with open("./metadata.json", "r") as metadataFile:
        return json.load(metadataFile)

def writeMetadataFile(meta):
    with open("./metadata.new.json", "w") as metadataFile:
        json.dump(meta, metadataFile)

def isNumeric(val):
    try:
        int(val)
        return True
    except ValueError:
        return False

def updateMetadata(file, meta):
    args = ["exiftool"]
    for k in meta["meta"]:
        v = meta["meta"][k]
        if isNumeric(v):
            args.append(f"-{k}={v}")
        else:
            args.append(f"-{k}=\"{v}\"")

    args.append(file)
    subprocess.run(args)

def renameFile(file, title, trackNumber):
    (name, ext) = os.path.splitext(file)
    finalName = f"{trackNumber:02}_{title}{ext}"
    os.rename(file, finalName)

    return finalName

def main():
    meta = readMetadataFile()

    track = 1;
    keys = list(meta["tracks"].keys());
    for filename in keys:
        #meta["meta"]["TrackNumber"] = track
        #meta["meta"]["SourceFile"] = filename
        #meta["meta"]["FileName"] = filename
        #updateMetadata(file, meta)
        newName = renameFile(filename, meta["tracks"][filename]["title"], meta["tracks"][filename]["to"])

        meta["tracks"][newName] = meta["tracks"][filename]
        del meta["tracks"][filename]

        track += 1

    writeMetadataFile(meta)

main()
