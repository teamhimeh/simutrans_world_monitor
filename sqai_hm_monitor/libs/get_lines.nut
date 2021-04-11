// メッセージ定義
local text_title = "%s の路線一覧（計 %d 路線） \n" //%sは会社名
local text_line = "%d : %s\n" //%dは番号， %sは路線名
local text_no_lines = "%s の路線は見当たりませんなあ．\n" //%dは番号， %sは路線名


include("libs/common")

class get_lines_cmd {
  // 路線の一覧を返す
  function exec(str) {
	local f = file(path_output,"w")
    local player = get_player_from_num(str, 1)
    if(player==null) {
      return //エラーメッセージは既に吐かれている．
    }
	local num = player.get_line_list().get_count()
	if(num == 0) {
      f.writestr(format(text_no_lines,player.get_name()))
      f.close() 
      return
    }
	local str = format(text_title, player.get_name(), num)
	
	//ワールド内の路線総数を取得
	local max = 0
	for(local i=0; i<20; i++) {
		local pl = player_x(i)
		if(pl.is_valid()) {
		max += pl.get_line_list().get_count()
		} 
	}
	
	//当該会社の路線一覧を取得
	for(local i=1; i<=max; i++) {
		local line = line_x(i)
		if(line.get_owner().get_name() == player.get_name()) {
			str += format(text_line, i, line.get_name())
		}
	}
    f.writestr(rstrip(str))
    f.close() 
  }
}
