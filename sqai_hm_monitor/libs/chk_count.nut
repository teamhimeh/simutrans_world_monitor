include("libs/monitoring_base")
include("libs/common")

class chk_count_cmd extends monitoring_base_cmd {
  count = 0
  
  constructor(m) {
    monthly_check_time = m
    count = 0
  }
  
  function do_check() {
    count += 1
    local f = file(path_output,"w")
    f.writestr(format("count: %d", count))
    f.close() 
  }
}
