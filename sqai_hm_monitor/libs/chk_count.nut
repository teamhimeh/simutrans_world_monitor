include("libs/monitoring_base")
include("libs/common")

class chk_count_cmd extends monitoring_base_cmd {
  
  constructor(m) {
    monthly_check_time = m
    //外部保存する変数はここで定義
    //第一引数はタスクの識別子。第二引数が外部保存する変数の名前と初期値。
    init_states("chk_count", [["count", 0]])
  }
  
  function do_check() {
    local ms = monitoring_state()
    print(format("check executed. %d", ms.state[task_name]["count"]))
    ms.state[task_name]["count"] += 1 //"state"を更新
    ms.save() //更新を書き出し
    local val = ms.state[task_name]["count"] //ms.state[task_name]["変数名"]で読み書き
    local f = file(path_output,"w")
    f.writestr(format("count: %d", val))
    f.close() 
  }
}
