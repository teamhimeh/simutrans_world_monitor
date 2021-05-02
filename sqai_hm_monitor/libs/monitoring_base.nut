include("libs/JSONEncoder.class")
include("libs/JSONParser.class")

class monitoring_base_cmd {
  states = []
  task_name = ""
  monthly_check_time = 4
  
  function init_states(name, vals) {
    task_name = name
    states = vals
    states.append(["last_check_tick", 0])
  }
  
  function check() {
    local ms = monitoring_state()
    ms.register(task_name, states) // stateの登録
    local last_check_tick = ms.state[task_name]["last_check_tick"]
    local tick = world.get_time().ticks
    if(tick-last_check_tick > world.get_time().ticks_per_month/monthly_check_time || last_check_tick-tick > world.get_time().ticks_per_month) {
      ms.state[task_name]["last_check_tick"] = tick
      do_check()
      return true
    } else {
      return false
    }
  }
  
  function do_check() {
    
  }
}

// monitoringタスクのstate保持用クラス
// 必要に応じて状態をJSONで読み書きする
class monitoring_state {
  state = {} // いわゆるstatic変数
    
  // varsは[変数名,初期値]の配列
  function register(name, vars) {
    if(!(name in state)) {
      state[name] <- {}
      foreach (v in vars) {
        state[name][v[0]] <- v[1]
      }
    }
  }
    
  // stateをstate.jsonの内容に置き換える
  function load() {
    try {
      local f = file(path_state,"r")
      local str = f.readstr(10000)
      f.close()
      if(str.len()==0) {
        return
      }
      local result = JSONParser.parse(str)
      local ms = monitoring_state()
      // ms.stateに直接resultを代入するとうまくいかないので，中身を更新
      ms.state.clear()
      foreach (key, val in result) {
        ms.state[key] <- val
      }
    } catch(e) {
      print(e)
      return
    }
  }
  
  function save() {
    local f = file(path_state,"w")
    f.writestr(JSONEncoder.encode(state))
    f.close()
  }
}
