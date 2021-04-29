
include("libs/global")
include("libs/get_waiting")
include("libs/get_players")
include("libs/get_overcrowded")
include("libs/get_time")
include("libs/get_stucked")
include("libs/get_finance")
include("libs/get_lines")
include("libs/get_halts")
include("libs/chk_count")

//コマンド一覧．不要な機能があればコメントアウトしてください．
commands["待機"] <- get_waiting_cmd()
commands["プレイヤー"] <- get_players_cmd()
commands["赤棒"] <- get_overcrowded_cmd()
commands["時間"] <- get_time_cmd()
commands["財務"] <- get_finances_cmd()
commands["路線"] <- get_lines_cmd()
commands["停車駅"] <- get_halts_cmd()

//モニタリング一覧．不要な機能があればコメントアウトしてください．
monitored.append(chk_overcrowded_cmd(8, 1.5, 1000)) //赤棒検知． 引数...(頻度,警報を出す倍率, 警報を出す下限)
monitored.append(chk_stucked_cmd(4, 0.8)) //デッドロック検知． 引数...(頻度,警報を出す割合)
//monitored.append(chk_count_cmd(64)) //動作確認用モニタリングタスク
