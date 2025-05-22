# MD5 Checker

A simple MD5 checksum verification tool built with Crystal and UIng.

## Installation

```bash
shards install
```

## Usage

Run the application:

```bash
shards build
bin/md5checker
```

## MD5 File Format

```
d41d8cd98f00b204e9800998ecf8427e file1.txt
900150983cd24fb0d6963f7d28e17f72 file2.txt
```

Each line contains an MD5 hash followed by a space and then the filename.
