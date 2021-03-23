//include("monitoring_base")

// playerがnullのときは全てのplayerを検査対象とする．
function _get_overcrowded_station(player) {
  local och = []
  foreach (h in halt_list_x()) {
    //なぜかinstanceの比較では==が通らない
    if(player==null || h.get_owner().get_name()==player.get_name()) {
      och.append(h)
    }
  }
  och = och.filter(@(i,h) h.get_waiting()[0]>h.get_capacity(good_desc_x.passenger))
  return och
}

class get_overcrowded_cmd {
  function exec(str) {
    local f = file(path_output,"w")
    local params = split(str,",")
    local player = null
    try{
      local num = params[1].tointeger()
      player = player_x(num-1)
    }catch(err) { 
      //ここではなにもしない．
    }
    if(player==null || !player.is_valid()) {
      f.writestr("そのプレイヤー番号はあかんわ．")
      f.close()
      return
    }
    
    local och = _get_overcrowded_station(player)
    local out_str = ""
    if(och.len()==0) {
      out_str = player.get_name() + " の駅に赤棒はないです．すばらしい．"
    } else {
      out_str = player.get_name() + " の赤棒駅はこれや！\n"
      foreach (h in och) {
        out_str += (h.get_name() + " ... " + h.get_waiting()[0].tostring() + "/" + h.get_capacity(good_desc_x.passenger).tostring() + "人\n")
      }
    }
    f.writestr(rstrip(out_str))
    f.close() 
  }
}

/*
class chk_overcrowded_cmd extends monitoring_base_cmd {
  function do_check() {
    local och = _get_overcrowded_station(null)
    local f = file(path_output,"w")
    f.writestr(rstrip(out_str))
    f.close() 
  }
}
*/

commands["赤棒"] <- get_overcrowded_cmd()
monitored.append(get_overcrowded_cmd())
