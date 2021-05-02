
include("libs/JSONEncoder.class")

/**
Discordにembedを出力するためにJSONを生成する関数群
color ... 16進数rgb
title ... タイトル。String
desc ... description。String
fields ... [[name, value]] 各要素はString
**/

// 緑
function embed_normal(title, desc=null, fields=null, footer=null) {
  embed_out(0x00ff00, title, desc, fields, footer)
}

// オレンジ
function embed_warn(title, desc=null, fields=null, footer=null) {
  embed_out(0xffbf00, title, desc, fields, footer)
}

// 赤
function embed_error(title, desc=null, fields=null, footer=null) {
  embed_out(0xff0000, title, desc, fields, footer)
}

function embed_out(color, title, desc, fields, footer) {
  local data = {}
  data["color"] <- color
  data["title"] <- title
  data["description"] <- desc
  data["fields"] <- fields==null ? null : 
    map(fields, (@(f) {name=f[0], value=f[1]}))
  data["footer"] <- footer
  local f = file(path_embed,"w")
  f.writestr(JSONEncoder.encode(data))
  f.close()
}
