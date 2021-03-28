
class get_time_cmd {
  // 今の時間を返す
  function exec(str) {
    local time = world.get_time()
    local f = file(path_output,"w")
	time.month = time.month + 1
    f.writestr("今？" + time.year + "年" + time.month + "月ちゃうか．")
    f.close() 
  }
}
