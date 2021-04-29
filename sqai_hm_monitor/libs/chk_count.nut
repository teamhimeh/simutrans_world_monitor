include("libs/monitoring_base")
include("libs/common")

class chk_count_cmd extends monitoring_base_cmd {
  pname = "chk_count"
  
  constructor(m) {
    monthly_check_time = m
  }
  
  function do_check() {
    local ms = monitoring_state()
    ms.register(pname,[["count", 0]]) //"count"を初期値0で定義
    print(format("check executed. %d", ms.state[pname]["count"]))
    ms.state[pname]["count"] += 1 //"state"を更新
    ms.save() //更新を書き出し
    local val = ms.state[pname]["count"]
    local f = file(path_output,"w")
    f.writestr(format("count: %d", val))
    f.close() 
  }
}
