// メッセージ定義
local text_require_param = "路線を番号で指定してな．"
local text_invalid_param = "%d 番の路線はあらへんで．"
local text_halt_title_rank = "%s （%s）が止まる駅で繁盛しとるんはこのへんや！ \n" //%sは停留所名, 会社名
local text_halt_rank = "%s 人 ... %s\n" //%sは乗降客数，駅名
local text_halt_caption_rank = "ちなみに利用者数は前の月やで．"
local text_halt_title_all = "%s （%s）はこんな感じにとまるで！ \n" //%sは停留所名, 会社名

include("libs/common")

class get_halts_cmd {
  
  function _min(a,b) {
    return a<b ? a : b
  }
  
  // "停車駅,XX" の形式でコマンドを受け取り，路線番号XXの現在の待機客数を返す．
  function exec(str) {
    local f = file(path_output,"w")
    local params = split(str,",")
    if(params.len()==1) {
      f.writestr(text_require_param)
      f.close() 
      return
    }
	
	// 路線番号に対応する路線があるか
	local line_num = params[1].tointeger()
    if(!(line_x(line_num).is_valid())) {
		f.writestr(format(text_invalid_param, line_num))
		f.close() 
		return
    }
	
	local line = line_x(line_num)
	local pl = line.get_owner()
    
    // 路線の停車駅を取得
	local schedule_entry = line.get_schedule().entries
	local schedule_halts = filter(schedule_entry, (@(e) e.get_halt(pl)!=null))
	schedule_halts.apply(@(e) e.get_halt(pl))
	local halts = map(schedule_halts, (@(h) [h, h.get_arrived()[1] + h.get_departed()[1]]))
	
	// 3つ目のパラメタ（自然数）の有無で分岐
	local num_of_halts = 0
	local out_str = ""
	if(params.len()>=3) {
      try{
        num_of_halts = params[2].tointeger()
      }catch(err) {
        // 3つ目のパラメタが整数にできなければスキップ
      }
    }
    if(num_of_halts > 0) {
		// 乗降客の多さでソートして出力
		halts.sort(@(a,b) b[1]<=>a[1])
		out_str += format(text_halt_title_rank, line.get_name() ,pl.get_name())
		
		local halt_name = null
		local n = 0
		for (local i=0; i<halts.len(); i++) {
			if(halts[i][0].get_name() != halt_name) {	//駅名（と乗降客数）が前の駅と一致→同一駅とする
				halt_name = halts[i][0].get_name()
				out_str += format(text_halt_rank, _comma_separate(halts[i][1].tostring()), halt_name)
				n += 1
			}
			if(n == num_of_halts) break
		}
		out_str += text_halt_caption_rank
		f.writestr(rstrip(out_str))
		f.close()
	}else{
		// 停車順に一覧を出力（重複を認める）
		out_str += format(text_halt_title_all, line.get_name() ,pl.get_name())
		for (local i=0; i<halts.len(); i++) {
			out_str += halts[i][0].get_name() + "\n"
		}
		f.writestr(rstrip(out_str))
		f.close()
	}
  }
}