import paramiko, sys, os, time

host = '78.46.204.144'
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(host, username='root', password='85ur3l[_/V*4', timeout=15)

def run(cmd, wait=15):
    stdin, stdout, stderr = client.exec_command(cmd)
    stdout.channel.settimeout(wait)
    try: out = stdout.read().decode('utf-8', errors='replace')
    except: out = ""
    try: err = stderr.read().decode('utf-8', errors='replace')
    except: err = ""
    combined = out.strip() + ("\n[ERR] " + err.strip() if err.strip() else "")
    if combined.strip():
        sys.stdout.buffer.write((combined.strip() + "\n").encode('utf-8'))
        sys.stdout.buffer.flush()

print("=== Uploading ===")
sftp = client.open_sftp()
base = os.path.dirname(os.path.abspath(__file__))
files = [
    ('backend/app/db/models/__init__.py',    '/root/YukGO/backend/app/db/models/__init__.py'),
    ('backend/app/main.py',                  '/root/YukGO/backend/app/main.py'),
    ('backend/app/services/fcm.py',          '/root/YukGO/backend/app/services/fcm.py'),
    ('backend/firebase-service-account.json','/root/YukGO/backend/firebase-service-account.json'),
    ('backend/requirements.txt',             '/root/YukGO/backend/requirements.txt'),
]
for local_rel, remote in files:
    sftp.put(os.path.join(base, local_rel), remote)
    print(f"  OK {local_rel}")
sftp.close()

print("\n=== pip install firebase-admin ===")
run("/root/YukGO/backend/venv/bin/pip install firebase-admin==6.5.0 -q", wait=120)
print("  Done")

print("\n=== Restart ===")
run("pkill -f 'uvicorn app.main' 2>/dev/null; echo ok")
time.sleep(2)
run("cd /root/YukGO/backend && nohup /root/YukGO/backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000 > /root/backend.log 2>&1 &")
time.sleep(5)

print("\n=== Health ===")
run("curl -s https://api.smart-tools.uk/health")

print("\n=== Log ===")
run("tail -25 /root/backend.log")

client.close()
print("\nDone!")
