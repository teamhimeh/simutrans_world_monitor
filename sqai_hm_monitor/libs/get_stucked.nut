include("libs/monitoring_base")
include("libs/common")

class chk_stucked_cmd extends monitoring_base_cmd {
  stucked_lines = []
  warning_ratio = 0.5
  
  constructor(m, wr) {
    monthly_check_time = m
    warning_ratio = wr
  }
  
  function _get_waiting_count(line) {
    local cnt = 0
    foreach (cnv in line.get_convoy_list()) {
      if(cnv.is_waiting()) {
        cnt += 1
      }
    }
    return cnt
  }
  
  function _get_stucked_lines(pl) {
    local stucked = []
    local wr = warning_ratio
    foreach (line in pl.get_line_list()) {
      local num_stucked = _get_waiting_count(line)
      if(num_stucked >= 5 && num_stucked >= line.get_convoy_list().get_count() * wr) {
        stucked.append(line)
      }
    }
    return stucked
  }
  
  function do_check() {
    local stucked = [] //渋滞路線リスト
    foreach (pl in get_player_list()) {
      stucked.extend(_get_stucked_lines(pl))
    }
    local prev_stucked = stucked_lines
    local new_stucked = stucked.filter(@(i,h) prev_stucked.filter(@(j,k) h.get_name()==k.get_name() && h.get_owner().get_name()==k.get_owner().get_name()).len()==0)
    stucked_lines = stucked
    if(new_stucked.len()==0) {
      // 新しく渋滞している路線はなし．
      return
    }
    
    //プレイヤーごとに，新しく渋滞した路線
    local pl_n_stucked = get_player_list().map(@(pl) [pl, new_stucked.filter(@(i, line) line.get_owner().get_name()==pl.get_name())])
    pl_n_stucked = pl_n_stucked.filter(@(i,p) p[1].len()>0)
    local out_str = "この路線渋滞してんで．やばいんとちゃうか．\n"
    foreach (pls in pl_n_stucked) {
      out_str += ("<" + pls[0].get_name() + ">\n")
      foreach (line in pls[1]) {
        out_str += (line.get_name() + "\n")
      }
    }
    local f = file(path_output,"w")
    f.writestr(rstrip(out_str))
    f.close()
  }
}
