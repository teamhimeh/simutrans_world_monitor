# -*- coding: utf-8 -*- 
# pip install discord.py watchdog

import discord
import os
import time
import asyncio
import hashlib
import config
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

FILE_CMD = config.DIRECTORY + '/file_io/cmd.txt'
FILE_OUT = config.DIRECTORY + '/file_io/out.txt'
waiting_message = None
# 接続に必要なオブジェクトを生成
client = discord.Client()
prev_out_hash = None #二重書き込み対策（主にWindows）

class FileChangeHandler(FileSystemEventHandler):
     # ファイル変更時のイベント
     def on_modified(self, event):
         filepath = event.src_path
         filename = os.path.basename(filepath)
         if(filename!="out.txt"):
             return
         with open(FILE_OUT, encoding='utf-8') as f:
             s = f.read()[:1990]
             hash = hashlib.md5(s.encode()).hexdigest()
             global prev_out_hash
             if s=='empty' or hash==prev_out_hash:
                 return
             prev_out_hash = hash
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
    await channel.send(config.TEXT_HELLO)

# メッセージ受信時に動作する処理
@client.event
async def on_message(message):
    channel = client.get_channel(config.CHANNEL_ID)
    # 指定チャンネルでの指定フォーマットの人間のメッセージのみ反応
    content = message.content.replace('？','?').replace('，',',')
    if message.author.bot or message.channel != channel or content[0]!='?' or len(content)<2:
        return
            
    with open(FILE_CMD, encoding='utf-8') as f:
        s = f.read()
        if s and not s.startswith('empty'):
            await channel.send(config.TEXT_BUSY)
            return
    with open(FILE_CMD, mode='w', encoding='utf-8') as f:
        global waiting_message
        f.write(content[1:])
        waiting_message = await channel.send(config.TEXT_WAIT)
        global prev_out_hash
        prev_out_hash = None
        
def generate_io_files():
    os.makedirs(config.DIRECTORY+'/file_io', exist_ok=True)
    if not os.path.isfile(FILE_CMD):
        with open(FILE_CMD, mode='w', encoding='utf-8') as f:
            f.write('empty')
    if not os.path.isfile(FILE_OUT):
        with open(FILE_OUT, mode='w', encoding='utf-8') as f:
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
