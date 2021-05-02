// メッセージ定義
local text_title = "この路線渋滞してんで．やばいんとちゃうか．\n"
local text_player_title = "<%s>\n" //%sはプレイヤー名

include("libs/monitoring_base")
include("libs/common")

class chk_stucked_cmd extends monitoring_base_cmd {
  stucked_lines = [] // stuckした路線の[名前,プレイヤー名]を保持する
  warning_ratio = 0.5
  
  constructor(m, wr) {
    monthly_check_time = m
    warning_ratio = wr
  }
  
  function _is_stucked_line(line) {
    local wr = warning_ratio
    local num_stucked = filter(line.get_convoy_list(), (@(c) c.is_waiting())).len()
    return num_stucked >= 5 && num_stucked >= line.get_convoy_list().get_count() * wr
  }
  
  // lineはstucked_linesの中に存在していないか？
  function _not_in_stucked_line(line) {
    local filtered = filter(stucked_lines, (@(s) s[0]==line.get_name() && s[1]==line.get_owner().get_name()))
    return filtered.len()==0
  }
  
  function do_check() {
    local ms = monitoring_state()
    local p_name = "chk_stucked_cmd"
    ms.register(p_name,[["sl", []]])
    // 渋滞路線をチェック
    stucked_lines = ms.state[p_name]["sl"]
    local stucked = [] // 渋滞路線リスト
    foreach (pl in get_player_list()) {
      stucked.extend(filter(pl.get_line_list(), _is_stucked_line))
    }
    local new_stucked = filter(stucked, _not_in_stucked_line)
    ms.state[p_name]["sl"] = map(stucked, (@(l) [l.get_name(), l.get_owner().get_name()])) //更新
    ms.save()
    if(new_stucked.len()==0) {
      // 新しく渋滞している路線はなし．
      return
    }
    
    //プレイヤーごとに，新しく渋滞した路線
    local pl_n_stucked = map(get_player_list(), (@(pl) [pl, filter(new_stucked, @( line) line.get_owner().get_name()==pl.get_name())]))
    pl_n_stucked = filter(pl_n_stucked, (@(p) p[1].len()>0))
    local out_str = text_title
    local pl_stucked_msgs = []
    foreach (pls in pl_n_stucked) {
      local out_str = ""
      foreach (line in pls[1]) {
        out_str += (line.get_name() + "\n")
      }
      pl_stucked_msgs.append([format(text_player_title, pls[0].get_name()), out_str])
    }
    embed_warn(text_title, null, pl_stucked_msgs)
  }
}
