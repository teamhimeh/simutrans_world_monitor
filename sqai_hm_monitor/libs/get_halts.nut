// メッセージ定義
local text_require_param = "路線を番号で指定してな．"
local text_invalid_param = "%s 番の路線はあらへんで．"
local text_halt_title_rank = "%s （%s）が止まる駅で繁盛しとるんはこのへんや！ \n" //%sは停留所名, 会社名
local text_halt_rank = "%s 人 ... %s\n" //%sは乗降客数，駅名
local text_halt_caption_rank = "ちなみに利用者数は前の月やで．"
local text_halt_title_all = "%s （%s）はこんな感じにとまるで！ \n" //%sは停留所名, 会社名
local text_halt_caption_overcrowded = "太字の駅は絶賛炎上中。えらいこっちゃ。"

include("libs/common")
include("libs/embed_out")

class get_halts_cmd {
  
  function _min(a,b) {
    return a<b ? a : b
  }
  
  function _get_unique(arr) {
    local new_arr = []
    foreach (e in arr) {
      if (new_arr.find(e)==null) {
        new_arr.push(e)
      }
    }
    return new_arr
  }
  
  // 自路線由来で赤棒状態になっているか判定する
  function _is_overcrowded(line, halt) {
    if(halt.get_waiting()[0]<halt.get_capacity(good_desc_x.passenger)) {
      return false // そもそも赤棒立ってない
    }
    
    // 路線の停留所名リストを取得する
    local schedule_halts = map(line.get_schedule().entries, (@(e) e.get_halt(line.get_owner())))
    schedule_halts = filter(schedule_halts, (@(h) h!=null)) //中継点除去
    schedule_halts = map(schedule_halts, (@(h) h.get_name())) //名前に変換
    schedule_halts = _get_unique(schedule_halts) //重複除去
    
    //路線所属駅への待機客を取得する
    local dest_halts = halt.get_connections(good_desc_x.passenger)
    local dests = map(dest_halts, (@(d) [d, halt.get_freight_to_halt(good_desc_x.passenger, d)])) //[[halt, 待機数]]
    dests = filter(dests, (@(d) d[1]>0)) //待機客0人を除外
    dests = filter(dests, (@(d) schedule_halts.find(d[0].get_name())!=null))
    
    local waiting_cnt = 0
    foreach (d in dests) {
      waiting_cnt += d[1]
    }
    return waiting_cnt>=halt.get_capacity(good_desc_x.passenger)
  }
  
  // 乗降客の多さでソートして出力
  function show_halts_sorted(line, halts, num_to_show) {
    halts.sort(@(a,b) b[1]<=>a[1])
    local halt_name = null
    local n = 0
    local halts_txt = ""
    for (local i=0; i<halts.len(); i++) {
      if(halts[i][0].get_name() != halt_name) {	//駅名（と乗降客数）が前の駅と一致→同一駅とする
        halt_name = halts[i][0].get_name()
        halts_txt += format(text_halt_rank, _comma_separate(halts[i][1].tostring()), halt_name)
        n += 1
      }
      if(n == num_to_show) {
        break
      }
    }
    local title = format(text_halt_title_rank, line.get_name() ,line.get_owner().get_name())
    embed_normal(title, halts_txt, null, text_halt_caption_rank)
  }
  
  // 停車順に一覧を出力（重複を認める）
  function show_halts_ordered(line, halts) {
    local halts_txt = ""
    local overcrowded_exists = false
    for (local i=0; i<halts.len(); i++) {
      local name = halts[i][0].get_name()
      if (_is_overcrowded(line, halts[i][0])) {
        halts_txt += "**" + name + "**\n" // 赤棒立ってる場合は太字にする
        overcrowded_exists = true
      } else {
        halts_txt += name + "\n"
      }
    }
    local title = format(text_halt_title_all, line.get_name() ,line.get_owner().get_name())
    if(overcrowded_exists) {
      embed_warn(title, halts_txt, null, text_halt_caption_overcrowded)
    } else {
      embed_normal(title, halts_txt)
    }
  }
  
  // "停車駅,XX" の形式でコマンドを受け取り，路線番号XXの現在の待機客数を返す．
  function exec(str) {
    local params = split(str,",")
    if(params.len()==1) {
      embed_error(text_require_param)
      return
    }
    
    // 路線番号に対応する路線があるか
    local line = null
    try {
      line = line_x(params[1].tointeger())
    } catch (err) {
      // pass
    }
    if(line==null || !line.is_valid()) {
      embed_error(format(text_invalid_param, params[1]))
      return
    }
    // lineには存在する路線が代入されていることが保証された
    
    // 路線の停車駅を取得
    local pl = line.get_owner()
    local schedule_entry = line.get_schedule().entries
    local schedule_halts = filter(schedule_entry, (@(e) e.get_halt(pl)!=null))
    schedule_halts.apply(@(e) e.get_halt(pl))
    local halts = map(schedule_halts, (@(h) [h, h.get_arrived()[1] + h.get_departed()[1]]))
    
    // 3つ目のパラメタ（自然数）の有無で分岐
    local halts_to_show = 0
    if(params.len()>=3) {
      try{
        halts_to_show = params[2].tointeger()
      }catch(err) {
        // 3つ目のパラメタが整数にできなければスキップ
      }
    }
    if(halts_to_show > 0) {
      show_halts_sorted(line, halts, halts_to_show)
    } else {
      show_halts_ordered(line, halts)
    }
  }
}
