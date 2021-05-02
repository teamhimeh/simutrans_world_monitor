// メッセージ定義
local text_title = "%s の%s路線一覧（計 %d 路線） \n" //%sは会社名、属性名。%dは路線数
local text_line = "%d : %s\n" //%dは番号， %sは路線名
local text_no_lines = "%s の路線は見当たりませんなあ．" //%dは番号， %sは路線名
local text_invalid_waytype_title = "路線属性 %s ←ないです" //%sは属性名
local text_invalid_waytype_desc = "指定可能な路線属性は以下のとおりです"

include("libs/common")
include("libs/embed_out")

class get_lines_cmd {
  wts = [["s", "自動車", wt_road], ["r", "鉄道", wt_rail], ["w", "船", wt_water], ["m", "ﾓﾉﾚｰﾙ", wt_monorail], ["g", "マグレブ", wt_maglev], ["t", "路面軌道", wt_tram], ["n", "ﾅﾛｰｹﾞｰｼﾞ", wt_narrowgauge], ["a", "航空", wt_air]]
  
  function get_waytype(param) {
    local wt = filter(wts, (@(wt) wt[0]==param))
    return wt.len()>0 ? wt[0] : null
  }
  
  // 路線の一覧を返す
  function exec(str) {
    local player = get_player_from_num(str, 1)
    if(player==null) {
      return //エラーメッセージは既に吐かれている．
    }
    local LINE_CNT = filter(player.get_line_list(), (@(l) l.is_valid())).len()
    if(LINE_CNT == 0) {
      embed_error(format(text_no_lines,player.get_name()))
      return
    }
    
    // waytype指定を抽出する
    local waytype = null
    local params = split(str,",")
    if(params.len()>=3) {
      waytype = get_waytype(params[2])
      if(waytype==null) {
        embed_error(format(text_invalid_waytype_title, params[2]), text_invalid_waytype_desc, wts)
        return
      }
    }
    
    // 路線のidがわからないので，プレイヤーの路線がすべて出現するまでイテレートする．
    local cnt = 0
    local wt_cnt = 0
    local lines_str = ""
    for(local i=0; cnt<LINE_CNT; i++) {
      local line = line_x(i)
      if(!line.is_valid() || line.get_owner().get_name() != player.get_name()) {
        continue
      }
      if(waytype==null || line.get_waytype()==waytype[2]) {
        lines_str += format(text_line, i, line.get_name())
        wt_cnt += 1
      }
      cnt += 1
    }
    
    local wt_name = waytype==null ? "" : waytype[1]
    local title = format(text_title, player.get_name(), wt_name, wt_cnt)
    embed_normal(title, rstrip(lines_str))
  }
}
