import paramiko, sys, time

host = '78.46.204.144'
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(host, username='root', password='85ur3l[_/V*4', timeout=15)

script = """
cd ~/YukGO
git pull origin main
pkill -f uvicorn 2>/dev/null
sleep 2
source backend/venv/bin/activate
cd backend
nohup uvicorn app.main:app --host 127.0.0.1 --port 8000 > /tmp/backend.log 2>&1 &
sleep 4
curl -s http://127.0.0.1:8000/
"""

stdin, stdout, stderr = client.exec_command(script, timeout=40)
out = stdout.read().decode('utf-8', errors='replace')
sys.stdout.buffer.write(out.encode('utf-8'))
sys.stdout.buffer.flush()
client.close()
