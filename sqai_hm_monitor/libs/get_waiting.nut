
// "待機,XX駅" の形式でコマンドを受け取り，XX駅の現在の待機客数を返す．
function get_waiting(str) {
  local params = split(str,",")
  local sta_name = strip(split(str,",")[1])
  local f = file(path_output,"w")
  //与えられた駅名をもつ駅を見つける
  foreach (halt in halt_list_x()) {
    if(halt.get_name()==sta_name) {
      local out_str = sta_name + "の待機客は" + halt.get_waiting()[0].tostring() + "人です．\n"
      f.writestr(out_str)
      f.close()
      return
    }
  }
  
  f.writestr("停車場" + sta_name + "が見つかりません．\n")
  f.close() 
}

commands["待機"] <- get_waiting
