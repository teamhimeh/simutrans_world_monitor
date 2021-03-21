# pip install discord.py watchdog
import discord
import os
import time
import asyncio
import config
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class FileChangeHandler(FileSystemEventHandler):
     # ファイル変更時のイベント
     def on_modified(self, event):
         filepath = event.src_path
         filename = os.path.basename(filepath)
         if(filename=="out.txt"):
             with open(config.DIRECTORY+'/out.txt') as f:
                 s = f.read()
                 if s!='empty':
                     coro = client.get_channel(config.CHANNEL_ID).send(s)
                     asyncio.run_coroutine_threadsafe(coro, client.loop)

# 接続に必要なオブジェクトを生成
client = discord.Client()

# 起動時に動作する処理
@client.event
async def on_ready():
    # 起動したらターミナルにログイン通知が表示される
    print('ログインしました')
    channel = client.get_channel(config.CHANNEL_ID)
    await channel.send('ﾃﾚｰ')

# メッセージ受信時に動作する処理
@client.event
async def on_message(message):
    channel = client.get_channel(config.CHANNEL_ID)
    # 指定チャンネルでの指定フォーマットの人間のメッセージのみ反応
    if message.author.bot or message.channel != channel or message.content[0]!='?':
        return
    # 情報出し入れ用のファイルの存在確認
    if not os.path.isfile(config.DIRECTORY+'/cmd.txt'):
        with open(config.DIRECTORY+'/cmd.txt', mode='w') as f:
            f.write('empty')
    if not os.path.isfile(config.DIRECTORY+'/out.txt'):
        with open(config.DIRECTORY+'/out.txt', mode='w') as f:
            f.write('empty')
            
    with open(config.DIRECTORY+'/cmd.txt') as f:
        s = f.read()
        print(s)
        if not s.startswith('empty'):
            await channel.send('今忙しいねん')
            return
    with open(config.DIRECTORY+'/cmd.txt', mode='w') as f:
        f.write(message.content[1:])
        await channel.send('応答待ち．ちょっとまってな．')
        
def start():
    event_handler = FileChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, config.DIRECTORY)
    observer.start()
    client.run(config.TOKEN)

# Botの起動とDiscordサーバーへの接続
start()
