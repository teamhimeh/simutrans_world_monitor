
//コマンド一覧．不要な機能があればコメントアウトしてください．
commands["待機"] <- get_waiting_cmd()
commands["プレイヤー"] <- get_players_cmd()
commands["赤棒"] <- get_overcrowded_cmd()

//モニタリング一覧．不要な機能があればコメントアウトしてください．
monitored.append(chk_overcrowded_cmd(8, 1.5)) //頻度, 警報を出す倍率
