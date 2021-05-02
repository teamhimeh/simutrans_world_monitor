// よく使うであろう関数をまとめたファイル．
// メッセージ定義
local text_invalid_idx = "そのプレイヤー番号はあかんわ．"

include("libs/embed_out")
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
    embed_error(text_invalid_idx)
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
    } 
  }
  return pl_list
}

function _step_generator(iteratable) {
  foreach (obj in iteratable) {
    yield obj
  }
}

function filter(array, func) {
  local new_array = []
  foreach (obj in _step_generator(array)) {
    if(func(obj)) {
      new_array.append(obj)
    }
  }
  return new_array
}

function map(array, func) {
  local new_array = []
  foreach (obj in _step_generator(array)) {
    new_array.append(func(obj))
  }
  return new_array
}

function _comma_separate(string) {
  local digit = 4 // 桁区切り
  local separated = ""
  while(string.len()>digit) {
    local len = string.len()
    separated = string.slice(len-digit,len) + separated
    if(len >= digit+1) separated = "," + separated
    string = string.slice(0,len-digit)
  }
  separated = string + separated
  return separated
}
