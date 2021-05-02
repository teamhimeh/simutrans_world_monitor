// メッセージ定義
local text_title = "このゲームには以下のプレイヤーが参戦中や！\n"
local text_player = "%d:%s\n" //%iは番号， %sはプレイヤー名

include("libs/common")
include("libs/embed_out")

class get_players_cmd {
  // プレイヤーの一覧を返す
  function exec(imp) {
    local str = ""
    for (local i=0; i<20; i++) {
      local pl = player_x(i)
      if(pl.is_valid()) {
        str += format(text_player, i+1, pl.get_name())
      } 
    }
    embed_normal(text_title, str)
  }
}
