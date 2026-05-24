import paramiko, sys, os, time

host = '78.46.204.144'
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(host, username='root', password='85ur3l[_/V*4', timeout=15)

def run(cmd, wait=30):
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

print("=== Uploading backend ===")
sftp = client.open_sftp()
base = os.path.dirname(os.path.abspath(__file__))

backend_files = [
    # endpoints
    ('backend/app/api/v1/endpoints/auth.py',   '/root/YukGO/backend/app/api/v1/endpoints/auth.py'),
    ('backend/app/api/v1/endpoints/orders.py', '/root/YukGO/backend/app/api/v1/endpoints/orders.py'),
    ('backend/app/api/v1/endpoints/chat.py',   '/root/YukGO/backend/app/api/v1/endpoints/chat.py'),
    # models
    ('backend/app/db/models/__init__.py',      '/root/YukGO/backend/app/db/models/__init__.py'),
    ('backend/app/db/models/message.py',       '/root/YukGO/backend/app/db/models/message.py'),
    ('backend/app/db/models/order.py',         '/root/YukGO/backend/app/db/models/order.py'),
    ('backend/app/db/models/user.py',          '/root/YukGO/backend/app/db/models/user.py'),
    # schemas & services
    ('backend/app/schemas/auth.py',            '/root/YukGO/backend/app/schemas/auth.py'),
    ('backend/app/services/auth_service.py',   '/root/YukGO/backend/app/services/auth_service.py'),
    ('backend/app/services/fcm.py',            '/root/YukGO/backend/app/services/fcm.py'),
    # main & config
    ('backend/app/main.py',                    '/root/YukGO/backend/app/main.py'),
    ('backend/requirements.txt',               '/root/YukGO/backend/requirements.txt'),
    # credentials
    ('backend/firebase-service-account.json',  '/root/YukGO/backend/firebase-service-account.json'),
]

for local_rel, remote in backend_files:
    local_path = os.path.join(base, local_rel)
    if os.path.exists(local_path):
        sftp.put(local_path, remote)
        print(f"  OK {local_rel}")
    else:
        print(f"  SKIP {local_rel} (not found locally)")

print("\n=== Uploading telegram bot ===")
bot_files = [
    ('telegram-bot/bot/handlers/contact.py', '/root/YukGO/telegram-bot/bot/handlers/contact.py'),
    ('telegram-bot/bot/main.py',             '/root/YukGO/telegram-bot/bot/main.py'),
    ('telegram-bot/bot/keyboards/reply.py',  '/root/YukGO/telegram-bot/bot/keyboards/reply.py'),
]
for local_rel, remote in bot_files:
    local_path = os.path.join(base, local_rel)
    if os.path.exists(local_path):
        sftp.put(local_path, remote)
        print(f"  OK {local_rel}")
    else:
        print(f"  SKIP {local_rel} (not found locally)")

sftp.close()

print("\n=== pip install (firebase-admin, websockets) ===")
run("/root/YukGO/backend/venv/bin/pip install firebase-admin==6.5.0 websockets -q", wait=120)
print("  Done")

print("\n=== Restart backend ===")
run("pkill -f 'uvicorn app.main' 2>/dev/null; echo ok")
time.sleep(2)
run("cd /root/YukGO/backend && nohup /root/YukGO/backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000 > /root/backend.log 2>&1 &")
time.sleep(5)

print("\n=== Restart telegram bot ===")
run("pkill -f 'python.*main.py' 2>/dev/null; pkill -f 'bot/main' 2>/dev/null; echo ok")
time.sleep(2)
run("cd /root/YukGO/telegram-bot && nohup /root/YukGO/telegram-bot/venv/bin/python -m bot.main > /root/bot.log 2>&1 &")
time.sleep(3)

print("\n=== Health check ===")
run("curl -s https://api.smart-tools.uk/health")

print("\n=== Backend log (last 30) ===")
run("tail -30 /root/backend.log")

print("\n=== Bot log (last 15) ===")
run("tail -15 /root/bot.log")

client.close()
print("\nDone!")
