// メッセージ定義
local text_title = "有り金はこんな感じや！\n"
local money_info = "%s:  %.2f￠\n"

include("libs/common")

class get_finances_cmd {
  // 各プレイヤーの手持ち資金を返す
  function exec(str) {
    local idx = 1
    local str = text_title
    foreach (player in get_player_list()) {
      str += format(money_info, player.get_name(), player.get_current_cash())
      idx += 1
    }
    local f = file(path_output,"w")
    f.writestr(rstrip(str))
    f.close() 
  }
}
