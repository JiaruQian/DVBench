import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from maintainer.runtime_policy import MUTANT_IDS, mutant_variants, ordered_sources


def inventory(directory):
    files = {}
    for path in sorted(directory.rglob('*')):
        if path.is_symlink():
            raise ValueError('Mutant assets must not contain symlinks: ' + str(path))
        if path.is_file():
            files[path.relative_to(directory).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    return files


def check(root):
    root = Path(root).resolve()
    catalog = json.loads((root / 'catalog.json').read_text())
    tasks = [root / 'maintainer/tasks' / row['task_id'] for row in catalog]
    for task in list(tasks):
        config = json.loads((task / 'task.json').read_text())
        tasks.extend(task / profile['task'] for profile in config.get('parameter_profiles', []) if 'task' in profile)
    if len(tasks) != len(set(task.resolve() for task in tasks)):
        raise ValueError('Duplicate task/profile roots')
    records = []
    for task in tasks:
        variants = mutant_variants(task)
        config = json.loads((task / 'task.json').read_text())
        source_order = ordered_sources(task, config)
        provenance_path = task / 'mutant-names.json'
        provenance = json.loads(provenance_path.read_text()) if provenance_path.exists() else None
        if provenance:
            entries = provenance['variants']
            if [entry['id'] for entry in entries] != list(MUTANT_IDS) or len({entry['previous_id'] for entry in entries}) != 10:
                raise ValueError('Invalid mutant name mapping: ' + str(task))
        hashes = {}
        for variant in variants:
            directory = task / config['mutant_root'].format(variant=variant)
            files = inventory(directory)
            if not source_order or any(name not in files for name in source_order):
                raise ValueError('Missing ordered compiler input: ' + str(directory))
            digest = hashlib.sha256(json.dumps(files, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
            hashes[variant] = digest
            if provenance:
                entry = next(entry for entry in provenance['variants'] if entry['id'] == variant)
                if digest != entry['tree_sha256']:
                    raise ValueError('Renaming changed mutant contents: ' + str(directory))
        evaluation_path = task / 'tests/evaluation_config.json'
        if evaluation_path.exists() and json.loads(evaluation_path.read_text()).get('fixed_mutants') != list(MUTANT_IDS):
            raise ValueError('Profile evaluation configuration has stale mutant IDs')
        records.append({'task': task.relative_to(root).as_posix(), 'mutants': hashes, 'compile_sources': source_order})
    return {'status': 'PASS', 'tasks': len(catalog), 'task_and_profile_roots': len(tasks),
            'variant_bindings': len(tasks) * 10, 'records': records}


def main():
    parser = argparse.ArgumentParser(description='Validate release mutant names, manifests, source closure and rename hashes')
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--output', type=Path)
    arguments = parser.parse_args()
    result = check(arguments.root)
    if arguments.output:
        arguments.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'records'}))


if __name__ == '__main__':
    main()
