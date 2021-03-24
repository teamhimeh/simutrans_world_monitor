
class get_waiting_cmd {
  
  function _min(a,b) {
    return a<b ? a : b
  }
  
  // "待機,XX駅" の形式でコマンドを受け取り，XX駅の現在の待機客数を返す．
  function exec(str) {
    local f = file(path_output,"w")
    local params = split(str,",")
    if(params.len()==1) {
      f.writestr("駅名を指定してな．")
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
      f.writestr("停車場 " + sta_name + " ←ないです．")
      f.close() 
      return
    }
    
    //目的地別のリストを作る
    local dest_halts = this_halt.get_connections(good_desc_x.passenger)
    local dests = dest_halts.map(@(d) [d, this_halt.get_freight_to_halt(good_desc_x.passenger, d)]) //[[halt, 待機数]]
    dests = dests.filter(@(i,d) d[1]>0) //待機客0人を除外
    dests.sort(@(a,b) b[1]<=>a[1]) //客の多さでソート．降順
    
    //結果を出力
    local out_str = sta_name + "の待機客は " + this_halt.get_waiting()[0].tostring() + "人/" + this_halt.get_capacity(good_desc_x.passenger).tostring() + "人 やね．\n"
    local num_of_dests = 5 //デフォルトでは5件
    if(params.len()>=3) {
      try{
        num_of_dests = params[2].tointeger()
      }catch(err) {
        // 無視
      }
    }
    for (local i=0; i<_min(num_of_dests, dests.len()); i++) {
      out_str += (dests[i][1].tostring() + "人 ... " + dests[i][0].get_name() + "\n")
    }
    f.writestr(rstrip(out_str))
    f.close()
  }
}
