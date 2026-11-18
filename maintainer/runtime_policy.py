import hashlib
from pathlib import Path
import math
import re
import shutil
import stat


SCOPE_PATTERN = r'[A-Za-z_]\w*(?:\[\d+\])?(?:\.[A-Za-z_]\w*(?:\[\d+\])?)*'
LICENSE_PATTERN = re.compile(
    r'failed to checkout|cannot checkout|unable to checkout|cannot connect to license server|'
    r'failed to obtain license|server node is down or not responding|license server does not support', re.I)


def ordered_sources(task, config):
    selected = config.get('rtl_compile_files', config.get('rtl_sources', config['rtl_files']))
    packages = []
    for name in config.get('rtl_sources', config['rtl_files']):
        source = Path(task) / config['rtl_root'] / name
        if source.suffix in {'.v', '.sv'} and source.is_file():
            text = re.sub(r'/\*.*?\*/|//[^\n]*', '', source.read_text(), flags=re.S)
            if re.search(r'\bpackage\s+(?:(?:automatic|static)\s+)?[A-Za-z_]\w*\s*;', text):
                packages.append(name)
    return list(dict.fromkeys(packages + [name for name in selected if name.endswith(('.v', '.sv'))]))


def validate_scopes(scopes):
    if not scopes or len(set(scopes)) != len(scopes):
        raise ValueError('Expected distinct elaborated native DUT scopes')
    if any(not re.fullmatch(SCOPE_PATTERN, scope) for scope in scopes):
        raise ValueError('Unsupported native DUT scope')
    return list(scopes)


def copy_shared_model(source, destination):
    source, destination = Path(source), Path(destination)
    if not source.is_dir() or source.is_symlink() or destination.exists():
        raise ValueError('Expected an ordinary frozen model directory and a new destination')
    destination.mkdir()
    destination.chmod(stat.S_IMODE(destination.stat().st_mode) | stat.S_IWUSR | stat.S_IXUSR)
    for child in source.iterdir():
        if child.is_symlink():
            raise ValueError('Frozen model must not contain symlinks')
        target = destination / child.name
        if child.is_dir():
            copy_shared_model(child, target)
        elif child.is_file() and child.stat().st_nlink == 1:
            shutil.copy2(child, target)
            if hashlib.sha256(child.read_bytes()).digest() != hashlib.sha256(target.read_bytes()).digest():
                raise ValueError('Shared model copy changed frozen contents')
        else:
            raise ValueError('Frozen model must contain ordinary independent files')
    shutil.copystat(source, destination)


def uvm_summary(path):
    counts = {}
    license_failure = False
    completed = False
    pattern = re.compile(r'^\s*UVM_(ERROR|FATAL)\s*:\s*(\d+)\s*$')
    with Path(path).open(errors='replace') as stream:
        for line in stream:
            match = pattern.match(line)
            if match:
                counts[match.group(1)] = int(match.group(2))
            license_failure = license_failure or bool(LICENSE_PATTERN.search(line))
            completed = completed or 'DVBench_COMPLETED' in line
    return dict(counts=counts, license_failure=license_failure, completion_marker=completed,
                summary_complete=set(counts) == {'ERROR', 'FATAL'})


def coverage_percent(covered, total):
    if isinstance(covered, bool) or isinstance(total, bool):
        raise ValueError('Coverage counts must be integers')
    if not isinstance(covered, int) or not isinstance(total, int) or not 0 <= covered <= total:
        raise ValueError('Invalid coverage counts')
    return None if total == 0 else 100 * covered / total


def overall_success(result):
    metrics = result.get('coverage', {})
    valid_coverage = all(
        isinstance(metrics.get(kind), (int, float)) and not isinstance(metrics.get(kind), bool)
        and math.isfinite(metrics[kind]) and 90 <= metrics[kind] <= 100
        for kind in ('LINE', 'COND', 'BRANCH', 'TOGGLE'))
    mutants = result.get('mutants', [])
    seeds = [1, 7, 42]
    if len(mutants) != 10 or len({entry.get('id') for entry in mutants}) != 10:
        return False
    golden = result.get('golden', {})
    return (result.get('compile_pass') is True
            and result.get('reference_model_percent') == 100
            and all(golden.get(str(seed)) == 'PASS' for seed in seeds)
            and all(entry.get('seeds', {}).get(str(seed)) == 'DETECTED'
                    for entry in mutants for seed in seeds)
            and valid_coverage)


def bind_coverage_scope(method, scopes):
    scopes = validate_scopes(scopes)
    configured = method.get('dut_instances', [])
    if configured and configured != scopes:
        raise ValueError('Coverage scope differs from elaborated candidate DUT instances')
    return dict(method, dut_instances=scopes)
