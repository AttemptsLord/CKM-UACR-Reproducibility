#!/usr/bin/env python3
from __future__ import annotations
import argparse, csv, hashlib, sys, urllib.request
from pathlib import Path

def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024), b''): h.update(block)
    return h.hexdigest()

def main() -> int:
    ap=argparse.ArgumentParser(description='Locate/download and verify frozen NHANES XPT inputs.')
    ap.add_argument('--download', action='store_true', help='Download missing files from the frozen official NCHS URLs.')
    ap.add_argument('--data-dir', default=None, help='Override data/raw directory.')
    ns=ap.parse_args()
    root=Path(__file__).resolve().parents[1]
    data=Path(ns.data_dir).resolve() if ns.data_dir else root/'data'/'raw'
    data.mkdir(parents=True, exist_ok=True)
    manifest=root/'config'/'SOURCE_FILE_FREEZE.csv'
    rows=list(csv.DictReader(manifest.open(newline='',encoding='utf-8')))
    failures=[]
    for r in rows:
        p=data/r['local_filename']
        if not p.exists():
            if not ns.download:
                failures.append(f"MISSING {r['local_filename']}")
                continue
            tmp=p.with_suffix(p.suffix+'.part')
            if tmp.exists(): tmp.unlink()
            print(f"Downloading {r['file_id']} from official NCHS source")
            urllib.request.urlretrieve(r['official_data_url'], tmp)
            tmp.replace(p)
        observed_size=p.stat().st_size
        observed_sha=sha256(p)
        if observed_size != int(r['byte_size']) or observed_sha != r['sha256']:
            failures.append(f"MISMATCH {r['local_filename']} bytes={observed_size} sha256={observed_sha}")
        else:
            print(f"OK {r['local_filename']} bytes={observed_size} sha256={observed_sha}")
    if failures:
        print('CKM_UACR_NHANES_INPUTS: FAIL', file=sys.stderr)
        for x in failures: print('- '+x, file=sys.stderr)
        return 1
    print(f"CKM_UACR_NHANES_INPUTS: PASS files={len(rows)}")
    return 0
if __name__=='__main__': raise SystemExit(main())
