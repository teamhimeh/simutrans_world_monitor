// よく使うであろう関数をまとめたファイル．

// str:受信文字列, idx:番号の位置
// だめなときはエラーメッセージを書き込んだ上でnullを返す．
function get_player_from_num(str, idx) {
  local params = split(str,",")
  local player = null
  try{
    local num = params[idx].tointeger()
    player = player_x(num-1)
  }catch(err) { 
    //ここではなにもしない．
  }
  if(player==null || !player.is_valid()) {
    local f = file(path_output,"w")
    f.writestr("そのプレイヤー番号はあかんわ．")
    f.close()
    return null
  } else {
    return player
  }
}

function get_player_list() {
  local pl_list = []
  for (local i=0; i<20; i++) {
    local pl = player_x(i)
    if(pl.is_valid()) {
      pl_list.append(pl)
    } else {
      break
    }
  }
  return pl_list
}
