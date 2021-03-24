class monitoring_base_cmd {
  monthly_check_time = 4
  last_check_tick = 0
  function check() {
    local tick = world.get_time().ticks
    if(tick-last_check_tick > world.get_time().ticks_per_month/monthly_check_time || last_check_tick-tick > world.get_time().ticks_per_month) {
      last_check_tick = tick
      do_check()
      return true
    } else {
      return false
    }
  }
  
  function do_check() {
    
  }
}
