
include("libs/global")
include("libs/get_waiting")
include("libs/get_players")

function start(pl_num) {
  
}

function resume_game(pl_num) {
  
}

function step() {
  local f = file(path_cmd,"r")
  if(f==null) {
    return
  }
  local head = f.readstr(5)
  f.close()
  if(head=="empty" || head.len()==0) {
    return
  }
  // 再度openして読む
  f = file(path_cmd,"r")
  local str = f.readstr(10000)
  f.close()
  local cmd_str = split(str,",").len()>1 ? split(str,",")[0] : strip(str)
  print("cmd_str: " + cmd_str)
  //コマンドがあれば実行する．
  if(cmd_str in commands) {
    commands[cmd_str].exec(str)
  } else {
    local f = file(path_output,"w")
    f.writestr("コマンド" + cmd_str + " ←ないです．")
    f.close()
  }
  f = file(path_cmd,"w")
  f.writestr("empty")
  f.close()  
  
}

function new_month() {
  
}
