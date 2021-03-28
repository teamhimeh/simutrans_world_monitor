include("libs/common")

class get_finances_cmd {
  // プレイヤーの総資産を返す
  function exec(str) {
    local idx = 1
    local str = "総資産はこんな感じや！\n"
    foreach (player in get_player_list()) {
      str += player.get_name() + " :         " + format("%.2f", player.get_current_cash()) + "￠\n"
      idx += 1
    }
    local f = file(path_output,"w")
    f.writestr(rstrip(str))
    f.close() 
  }
}
