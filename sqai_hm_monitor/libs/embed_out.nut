
include("libs/JSONEncoder.class")

// Discordにembedを出力するためにJSONを生成する関数群

// 緑
function embed_normal(title, desc=null, fields=null) {
  _embed_out(0x00ff00, title, desc, fields)
}

// オレンジ
function embed_warn(title, desc=null, fields=null) {
  _embed_out(0xffbf00, title, desc, fields)
}

// 赤
function embed_error(title, desc=null, fields=null) {
  _embed_out(0xff0000, title, desc, fields)
}

function _embed_out(color, title, desc, fields) {
  local data = {}
  data["color"] <- color
  data["title"] <- title
  data["description"] <- desc
  if(fields!=null) {
    
  }
  local f = file(path_embed,"w")
  f.writestr(JSONEncoder.encode(data))
  f.close()
}
