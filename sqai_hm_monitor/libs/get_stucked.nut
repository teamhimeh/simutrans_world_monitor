// メッセージ定義
local text_title = "この路線渋滞してんで．やばいんとちゃうか．\n"
local text_player_title = "<%s>\n" //%sはプレイヤー名

include("libs/monitoring_base")
include("libs/common")

class chk_stucked_cmd extends monitoring_base_cmd {
  stucked_lines = []
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
    local filtered = filter(stucked_lines, (@(s) s.get_name()==line.get_name() && s.get_owner().get_name()==line.get_owner().get_name()))
    return filtered.len()==0
  }
  
  function do_check() {
    local stucked = [] //渋滞路線リスト
    foreach (pl in get_player_list()) {
      stucked.extend(filter(pl.get_line_list(), _is_stucked_line))
    }
    local new_stucked = filter(stucked, _not_in_stucked_line)
    stucked_lines = stucked //更新
    if(new_stucked.len()==0) {
      // 新しく渋滞している路線はなし．
      return
    }
    
    //プレイヤーごとに，新しく渋滞した路線
    local pl_n_stucked = map(get_player_list(), (@(pl) [pl, filter(new_stucked, @( line) line.get_owner().get_name()==pl.get_name())]))
    pl_n_stucked = filter(pl_n_stucked, (@(p) p[1].len()>0))
    local out_str = text_title
    foreach (pls in pl_n_stucked) {
      out_str += format(text_player_title, pls[0].get_name())
      foreach (line in pls[1]) {
        out_str += (line.get_name() + "\n")
      }
    }
    local f = file(path_output,"w")
    f.writestr(rstrip(out_str))
    f.close()
  }
}
