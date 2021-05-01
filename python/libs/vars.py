import discord

client = discord.Client()
waiting_message = None
prev_out_hash = None #二重書き込み対策（主にWindows）

def get_waiting_message():
    return waiting_message

def set_waiting_message(msg):
    global waiting_message
    waiting_message = msg

def get_prev_out_hash():
    return prev_out_hash

def set_prev_out_hash(hash):
    global prev_out_hash
    prev_out_hash = hash
