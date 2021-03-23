
class get_players_cmd {
  // プレイヤーの一覧を返す
  function exec(str) {
    local num_of_players = 0
    for (local i=0; i<30; i++) {
      if(player_x(i).is_valid()) {
        num_of_players = i+1
      } else {
        break
      }
    }
    local str = "このゲームには以下のプレイヤーが参戦中や！\n"
    for (local i=0; i<num_of_players; i++) {
      str += (i+1).tostring() + ":" + player_x(i).get_name()
      if(i<num_of_players-1) {
        str += "\n"
      }
    }
    local f = file(path_output,"w")
    f.writestr(str)
    f.close() 
  }
}

commands["プレイヤー"] <- get_players_cmd()
