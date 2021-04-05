
include("libs/global")
include("libs/get_waiting")
include("libs/get_players")
include("libs/get_overcrowded")
include("libs/get_time")
include("libs/get_stucked")
include("libs/get_finance")

//コマンド一覧．不要な機能があればコメントアウトしてください．
commands["待機"] <- get_waiting_cmd()
commands["プレイヤー"] <- get_players_cmd()
commands["赤棒"] <- get_overcrowded_cmd()
commands["時間"] <- get_time_cmd()
commands["財政"] <- get_finances_cmd()

//モニタリング一覧．不要な機能があればコメントアウトしてください．
monitored.append(chk_overcrowded_cmd(8, 1.5, 1000)) //赤棒検知． 引数...(頻度,警報を出す倍率, 警報を出す下限)
monitored.append(chk_stucked_cmd(4, 0.8)) //デッドロック検知． 引数...(頻度,警報を出す割合)
