# pip install discord.py watchdog
import discord
import os
import time
import asyncio
import config
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

FILE_CMD = config.DIRECTORY + '/file_io/cmd.txt'
FILE_OUT = config.DIRECTORY + '/file_io/out.txt'
waiting_message = None
# 接続に必要なオブジェクトを生成
client = discord.Client()

class FileChangeHandler(FileSystemEventHandler):
     # ファイル変更時のイベント
     def on_modified(self, event):
         filepath = event.src_path
         filename = os.path.basename(filepath)
         if(filename!="out.txt"):
             return
         with open(FILE_OUT) as f:
             s = f.read()
             if s=='empty':
                 return
             ch = client.get_channel(config.CHANNEL_ID)
             global waiting_message
             if waiting_message!=None:
                 coro = ch.delete_messages([waiting_message])
                 asyncio.run_coroutine_threadsafe(coro, client.loop)
                 waiting_message = None
             coro = ch.send(s)
             asyncio.run_coroutine_threadsafe(coro, client.loop)

# 起動時に動作する処理
@client.event
async def on_ready():
    # 起動したらターミナルにログイン通知が表示される
    channel = client.get_channel(config.CHANNEL_ID)
    await channel.send('おはようさん．?をつけてなんでもいうてな．')

# メッセージ受信時に動作する処理
@client.event
async def on_message(message):
    channel = client.get_channel(config.CHANNEL_ID)
    # 指定チャンネルでの指定フォーマットの人間のメッセージのみ反応
    if message.author.bot or message.channel != channel or message.content[0]!='?':
        return
            
    with open(FILE_CMD) as f:
        s = f.read()
        if not s.startswith('empty'):
            await channel.send('今忙しいねん')
            return
    with open(FILE_CMD, mode='w') as f:
        global waiting_message
        f.write(message.content[1:])
        waiting_message = await channel.send('応答待ち．ちょっとまってな．')
        
def generate_io_files():
    os.makedirs(config.DIRECTORY+'/file_io', exist_ok=True)
    if not os.path.isfile(FILE_CMD):
        with open(FILE_CMD, mode='w') as f:
            f.write('empty')
    if not os.path.isfile(FILE_OUT):
        with open(FILE_OUT, mode='w') as f:
            f.write('empty')

def start():
    generate_io_files()
    event_handler = FileChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, config.DIRECTORY+'/file_io')
    observer.start()
    client.run(config.TOKEN)

# Botの起動とDiscordサーバーへの接続
start()
