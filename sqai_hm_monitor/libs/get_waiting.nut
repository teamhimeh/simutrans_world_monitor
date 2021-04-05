// メッセージ定義
local text_require_param = "駅名を指定してな．"
local text_invalid_param = "停車場 %s ←ないです．"
local text_waiting_title = "%sの待機客は %d/%d人やね．\n" //%sは停留所名，%dは待機客数，停留所容量
local text_dest_info = "%d人 ... %s\n" //%dは待機客数，%sは目的地

class get_waiting_cmd {
  
  function _min(a,b) {
    return a<b ? a : b
  }
  
  // "待機,XX駅" の形式でコマンドを受け取り，XX駅の現在の待機客数を返す．
  function exec(str) {
    local f = file(path_output,"w")
    local params = split(str,",")
    if(params.len()==1) {
      f.writestr(text_require_param)
      f.close() 
      return
    }
    local sta_name = strip(params[1])
    //与えられた駅名をもつ駅を見つける
    local this_halt = null
    foreach (h in halt_list_x()) {
      if(h.get_name()==sta_name) {
        this_halt = h
        break
      }
    }
    if(this_halt==null) {
      f.writestr(format(text_invalid_param, sta_name))
      f.close() 
      return
    }
    
    //目的地別のリストを作る
    local dest_halts = this_halt.get_connections(good_desc_x.passenger)
    local dests = map(dest_halts, (@(d) [d, this_halt.get_freight_to_halt(good_desc_x.passenger, d)])) //[[halt, 待機数]]
    dests = filter(dests, (@(d) d[1]>0)) //待機客0人を除外
    dests.sort(@(a,b) b[1]<=>a[1]) //客の多さでソート．降順
    
    //結果を出力
    local out_str = format(text_waiting_title, sta_name, this_halt.get_waiting()[0], this_halt.get_capacity(good_desc_x.passenger))
    local num_of_dests = 5 //デフォルトでは5件
    if(params.len()>=3) {
      try{
        num_of_dests = params[2].tointeger()
      }catch(err) {
        // 無視
      }
    }
    for (local i=0; i<_min(num_of_dests, dests.len()); i++) {
      out_str += format(text_dest_info, dests[i][1], dests[i][0].get_name())
    }
    f.writestr(rstrip(out_str))
    f.close()
  }
}
