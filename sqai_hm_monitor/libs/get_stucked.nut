// メッセージ定義
local text_title = "この路線渋滞してんで．やばいんとちゃうか．\n"
local text_player_title = "<%s>\n" //%sはプレイヤー名

include("libs/monitoring_base")
include("libs/common")
include("libs/embed_out")

class chk_stucked_cmd extends monitoring_base_cmd {
  stucked_lines = [] // stuckした路線の[名前,プレイヤー名]を保持する
  warning_ratio = 0.5
  
  constructor(m, wr) {
    monthly_check_time = m
    warning_ratio = wr
    init_states("chk_stucked_cmd", [["sl", []]])
  }
  
  // convoyの座標が車庫かどうか
  // 出庫待ちの編成を判定から除外する
  function _is_in_depot(cnv) {
    local pos = cnv.get_pos()
    local tile = tile_x(pos.x, pos.y, pos.z)
    local mo_depots = [mo_depot_rail, mo_depot_road, mo_depot_water, mo_depot_air, mo_depot_monorail, mo_depot_tram, mo_depot_maglev, mo_depot_narrowgauge]
    foreach (m in mo_depots) {
      if(tile!=null && tile.find_object(m)!=null) {
        return true
      }
    }
    return false
  }
  
  function _is_stucked_line(line) {
    local wr = warning_ratio
    local cnv_to_check = filter(line.get_convoy_list(), (@(c) !c.is_in_depot()))
    local num_stucked = filter(cnv_to_check, (@(c) c.is_waiting() && !_is_in_depot(c))).len()
    return num_stucked >= 5 && num_stucked >= cnv_to_check.len() * wr
  }
  
  // lineはstucked_linesの中に存在していないか？
  function _not_in_stucked_line(line) {
    local filtered = filter(stucked_lines, (@(s) s[0]==line.get_name() && s[1]==line.get_owner().get_name()))
    return filtered.len()==0
  }
  
  function do_check() {
    local ms = monitoring_state()
    // 渋滞路線をチェック
    stucked_lines = ms.state[task_name]["sl"]
    local stucked = [] // 渋滞路線リスト
    foreach (pl in get_player_list()) {
      stucked.extend(filter(pl.get_line_list(), _is_stucked_line))
    }
    local new_stucked = filter(stucked, _not_in_stucked_line)
    ms.state[task_name]["sl"] = map(stucked, (@(l) [l.get_name(), l.get_owner().get_name()])) //更新
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
