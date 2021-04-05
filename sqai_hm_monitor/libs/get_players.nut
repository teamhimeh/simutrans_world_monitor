// メッセージ定義
local text_title = "このゲームには以下のプレイヤーが参戦中や！\n"
local text_player = "%d:%s\n" //%iは番号， %sはプレイヤー名

include("libs/common")

class get_players_cmd {
  // プレイヤーの一覧を返す
  function exec(str) {
    local idx = 1
    local str = text_title
    foreach (player in get_player_list()) {
      str += format(text_player, idx, player.get_name())
      idx += 1
    }
    local f = file(path_output,"w")
    f.writestr(rstrip(str))
    f.close() 
  }
}
