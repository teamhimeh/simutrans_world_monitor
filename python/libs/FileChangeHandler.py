import config
import os
import hashlib
import asyncio
from watchdog.events import FileSystemEventHandler
from libs.vars import *

FILE_OUT = config.DIRECTORY + '/file_io/out.txt'

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
             if s=='empty' or hash==get_prev_out_hash():
                 return
             set_prev_out_hash(hash)
             ch = client.get_channel(config.CHANNEL_ID)
             if get_waiting_message()!=None:
                 coro = ch.delete_messages([get_waiting_message()])
                 asyncio.run_coroutine_threadsafe(coro, client.loop)
                 set_waiting_message(None)
             coro = ch.send(s)
             asyncio.run_coroutine_threadsafe(coro, client.loop)
