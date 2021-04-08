// メッセージ定義
local text_title = "このゲームには以下のプレイヤーが参戦中や！\n"
local text_player = "%d:%s\n" //%iは番号， %sはプレイヤー名

include("libs/common")

class get_players_cmd {
  // プレイヤーの一覧を返す
  function exec(str) {
    local str = text_title
	for (local i=0; i<20; i++) {
		local pl = player_x(i)
		if(pl.is_valid()) {
			str += format(text_player, i+1, pl.get_name())
		} 
	}
    local f = file(path_output,"w")
    f.writestr(rstrip(str))
    f.close() 
  }
}
