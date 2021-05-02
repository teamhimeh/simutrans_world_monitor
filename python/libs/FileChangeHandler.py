import config
import os
import hashlib
import asyncio
import json
import discord
from watchdog.events import FileSystemEventHandler
from libs.vars import *

FILE_OUT = config.DIRECTORY + '/file_io/out.txt'
FILE_EMBED = config.DIRECTORY + '/file_io/out_embed.json'

class FileChangeHandler(FileSystemEventHandler):
    def remove_waiting_message(self, ch):
        if get_waiting_message()!=None:
            coro = ch.delete_messages([get_waiting_message()])
            asyncio.run_coroutine_threadsafe(coro, client.loop)
            set_waiting_message(None)
            
    def is_same_message(self, str):
        hash = hashlib.md5(str.encode()).hexdigest()
        if hash==get_prev_out_hash():
            return True
        else:
            set_prev_out_hash(hash)
            return False
    
    def plain_text_out(self):
        with open(FILE_OUT, encoding='utf-8') as f:
            s = f.read()[:1990]
            if s=='empty' or self.is_same_message(s):
                return
            ch = client.get_channel(config.CHANNEL_ID)
            self.remove_waiting_message(ch)
            coro = ch.send(s)
            asyncio.run_coroutine_threadsafe(coro, client.loop)
                            
    def embed_out(self):
        with open(FILE_EMBED, encoding='utf-8') as f:
            s = f.read()
            if len(s)==0 or self.is_same_message(s):
                return
            ch = client.get_channel(config.CHANNEL_ID)
            self.remove_waiting_message(ch)
            jo = json.JSONDecoder().raw_decode(s)[0]
            embed = discord.Embed(title=jo["title"], description=jo["description"], color=jo["color"])
            if jo["fields"]:
                for f in jo["fields"]:
                    embed.add_field(name=f["name"], value=f["value"], inline=True)
            if jo["footer"]:
                embed.set_footer(text=jo["footer"])
            coro = ch.send(embed=embed)
            asyncio.run_coroutine_threadsafe(coro, client.loop)
        
    # ファイル変更時のイベント
    def on_modified(self, event):
        filepath = event.src_path
        filename = os.path.basename(filepath)
        if filename=="out.txt" :
            self.plain_text_out()
        elif filename=="out_embed.json" :
            self.embed_out()
            pass
