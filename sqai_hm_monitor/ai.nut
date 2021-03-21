
include("libs/global")
include("libs/get_waiting")

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
  if(head=="empty") {
    return
  }
  // 再度openして読む
  f = file(path_cmd,"r")
  local str = f.readstr(10000)
  f.close()
  if(split(str,",").len()>1) {
    local cmd_str = split(str,",")[0]
    print("cmd_str: " + cmd_str)
    if(cmd_str in commands) {
      commands[cmd_str](str)
    }
  }
  f = file(path_cmd,"w")
  f.writestr("empty")
  f.close()  
  
}

function new_month() {
  
}
