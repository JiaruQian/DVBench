import fcntl
import json
from pathlib import Path
import sys


def main():
    event = json.load(sys.stdin)
    transcript = Path(event['transcript_path'])
    ledger_path = Path(sys.argv[1])
    ledger_path.parent.mkdir(parents=True, exist_ok=True)
    with ledger_path.with_suffix('.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        ledger = json.loads(ledger_path.read_text()) if ledger_path.exists() else {'message_ids': [], 'reminded': False}
        observed = set(ledger['message_ids'])
        for line in transcript.read_text().splitlines():
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            if item.get('type') == 'assistant' and item.get('message', {}).get('id'):
                observed.add(item['message']['id'])
        ledger['message_ids'] = sorted(observed)
        reminder = len(observed) >= 250 and not ledger['reminded']
        if reminder:
            ledger['reminded'] = True
        temporary = ledger_path.with_suffix('.tmp')
        temporary.write_text(json.dumps(ledger) + '\n')
        temporary.replace(ledger_path)
    if reminder:
        print(json.dumps({'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'additionalContext': 'DVBENCH_TURN_REMINDER: At least 250 of 300 decision turns have been used. Finish all required deliverables and known repairs, preserve your files, and report actual verification status. Do not restart the budget.'
        }}))


if __name__ == '__main__':
    main()
