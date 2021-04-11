// メッセージ定義
local text_title = "%s の路線一覧（計 %d 路線） \n" //%sは会社名
local text_line = "%d : %s\n" //%dは番号， %sは路線名
local text_no_lines = "%s の路線は見当たりませんなあ．" //%dは番号， %sは路線名


include("libs/common")

class get_lines_cmd {
  // 路線の一覧を返す
  function exec(str) {
    local f = file(path_output,"w")
    local player = get_player_from_num(str, 1)
    if(player==null) {
      return //エラーメッセージは既に吐かれている．
    }
    local LINE_CNT = filter(player.get_line_list(), (@(l) l.is_valid())).len()
    if(LINE_CNT == 0) {
      f.writestr(format(text_no_lines,player.get_name()))
      f.close() 
      return
    }
    local str = format(text_title, player.get_name(), LINE_CNT)
    
    // 路線のidがわからないので，プレイヤーの路線がすべて出現するまでイテレートする．
    local cnt = 0
    for(local i=0; cnt<LINE_CNT; i++) {
      local line = line_x(i)
      if(line.is_valid() && line.get_owner().get_name() == player.get_name()) {
        str += format(text_line, i, line.get_name())
        cnt += 1
      }
    }
    
    f.writestr(rstrip(str))
    f.close() 
  }
}
