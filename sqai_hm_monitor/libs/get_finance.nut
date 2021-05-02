// メッセージ定義
local text_title = "有り金はこんな感じや！\n"
local text_money_info = "%s:  %s￠\n"

include("libs/common")
include("libs/embed_out")

class get_finances_cmd {
  // 各プレイヤーの手持ち資金を返す
  function exec(str) {
    local idx = 1
    local str = ""
    foreach (player in get_player_list()) {
      local cash = _comma_separate(format("%.f",player.get_current_cash()))
      str += format(text_money_info, player.get_name(), cash)
      idx += 1
    }
    embed_normal(text_title, str)
  }
}
