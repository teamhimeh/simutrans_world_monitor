
include("libs/global")
include("libs/get_waiting")
include("libs/get_players")
include("libs/get_overcrowded")
include("libs/get_time")
include("libs/get_stucked")
include("config")

function start(pl_num) {
  
}

function resume_game(pl_num) {
  
}

// リクエストが実行されたときにはtrueを返す．
function process_request() {
  local f = file(path_cmd,"r")
  if(f==null) {
    return false
  }
  local head = f.readstr(5)
  f.close()
  if(head=="empty" || head.len()==0) {
    return false
  }
  // 再度openして読む
  f = file(path_cmd,"r")
  local str = f.readstr(10000)
  f.close()
  local cmd_str = split(str,",").len()>1 ? split(str,",")[0] : strip(str)
  //コマンドがあれば実行する．
  if(cmd_str in commands) {
    commands[cmd_str].exec(str)
  } else {
    local f = file(path_output,"w")
    f.writestr("コマンド" + cmd_str + " ←ないです．\n使い方はココ見てな．\n https://github.com/teamhimeh/simutrans_world_monitor#使用方法")
    f.close()
  }
  f = file(path_cmd,"w")
  f.writestr("empty")
  f.close() 
  return true
}

function step() {
   if(process_request()) {
     // 負荷軽減のため，モニタリングタスクは先送り．
     return
   }
   foreach (m in monitored) {
     if(m.check()) {
       // 負荷軽減のため，モニタリングタスクは1つのみ実行．
       return
     }
   }
}

function new_month() {
  
}
