import pathlib
import subprocess


data_root = '/data'

# get current files, exclude most recent and current
flow_files = [ i for i in pathlib.Path(data_root).rglob('nfcapd.[!current]*') ]
flow_files.sort()
flow_files.pop()

# dump data and detele file
for f in flow_files:
    with open(F'/log/{f.name}.csv', 'w') as out_file:
        cmd_string = ['/usr/local/bin/nfdump', '-r', f, '-q', '-o', 'csv', '-o', 'extended']
        subprocess.run(cmd_string, stdout=out_file)
    f.unlink()

# remove empty directories
for p in pathlib.Path(data_root).rglob('**/*'):
    if p.is_dir() and len(list(p.iterdir())) == 0:
        p.rmdir()