@echo off
echo Starting YukGo Telegram Bot...
cd /d "%~dp0telegram-bot"
python -m pip install -r requirements.txt -q
python -m bot.main
pause
