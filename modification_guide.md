# 機能追加方法

このドキュメントは，simutrans world monitorにコマンドやモニタリングタスクを追加する方法を説明するものです．

いじるのはSquirrelコードだけであり，Pythonコードはいじりません．

## 情報源

- [Squirrel documentation](http://www.squirrel-lang.org/squirreldoc/index.html)
- [Simutrans Squirrel API](http://dwachs.github.io/simutrans-sqapi-doc/index.html)
- [日本語化Wiki（Tips集）](https://japanese.simutrans.com/index.php?%A5%B9%A5%AF%A5%EA%A5%D7%A5%C8%B3%AB%C8%AF%2FTips%BD%B8)

## コマンドを追加する

新しいコマンドを追加するには

1. libs下にnutファイルを作成し，`exec()` 関数を持つclassを実装
2. config.nutで，libs下のnutファイルをincludeし，`commands` ディクショナリにインスタンスを登録

の手順を踏みます．例として，文字列をそのまま返す「復唱」コマンドを作ってみましょう．

discordで`?復唱,こんにちは` と入力したときに，`復唱！こんにちは` と返ってくるようにします．

`libs/get_echo.nut` を実装ファイルとして作成します．中身はこうなるでしょう．

```squirrel
// メッセージ定義．出力文字列はこのようにロジックから分離しましょう．
local text_echo = "復唱！%s"

class get_echo_cmd {
  function exec(str) {
    // strは，「復唱,こんにちは」という文字列が渡される．discordの文字列から冒頭の?を抜いた形．
    local params = split(str,",") // カンマで区切って配列にする
    local f = file(path_output,"w") // 出力用ファイルオブジェクトを取得
    f.writestr(format(text_echo, params[1])) // 文字列を書き込む
    f.close() // ファイルをclose
  }
}
```

※このコードでは，`?復唱` とだけ投げられたときに`params[1]` が存在せずエラーになるので，実際に運用する際は対策が必要です．

`libs/get_echo.nut` を作成したら，`config.nut` で以下のように追記します．

```squirrel
include("libs/get_echo") // libs/get_echo.nutをincludeする
commands["復唱"] <- get_echo_cmd() // コマンド名と実行インスタンスを紐付ける
```

これで，`get_echo_cmd` クラスの`exec()` 関数が呼ばれるようになりました．

## モニタリングタスクを追加する

モニタリングタスクの場合は，

1. `monitoring_base_cmd` を継承したクラスを作成し，
2. config.nutで，libs下のnutファイルをincludeし，`monitored` 配列にインスタンスを追加

の手順を踏みます．例えば，デッドロックを検知する`libs/get_stucked.nut` は下のようになっています．

```squirrel
include("libs/monitoring_base")

// モニタリングタスクのclass名プレフィックスは'chk'がおすすめ．
class chk_stucked_cmd extends monitoring_base_cmd {
  stucked_lines = []
  warning_ratio = 0.5
  
  constructor(m, wr) {
    monthly_check_time = m // do_check()を行う間隔を，1ヶ月あたりの回数で指定
    warning_ratio = wr // デッドロック検出閾値
  }
  
  function do_check() {
    // 実際にチェックを行い，必要に応じてdiscordに通知する
  	// 中身省略
  }
}
```

モニタリングタスクの場合は，コンストラクタで`monthly_check_time` の指定が必要です．`chk_stucked_cmd` の場合は，インスタンス作成時にチェック頻度と検知閾値`wr` を設定します．

`do_check()` 内でdiscordにメッセージを送るには，コマンドを実装するときと同じように，出力用ファイルオブジェクトを取得し，そこに文字列を書き込みます．

最後に，`config.nut` で以下のように追記します．

```squirrel
include("libs/get_stucked") // libs/get_stucked.nutをincludeする
monitored.append(chk_stucked_cmd(8, 0.8)) // パラメータを指定しながら登録
```

## common.nut について

`libs/common.nut` をincludeすると，

- map（squirrel standard libraryの[array.map()で生じる諸問題](https://japanese.simutrans.com/index.php?%A5%B9%A5%AF%A5%EA%A5%D7%A5%C8%B3%AB%C8%AF%2FTips%BD%B8#a1ada227) に対処しています）
- filter（同上）
- プレイヤー番号からプレイヤーobjectを取得
- プレイヤーobject一覧を取得

などができるようになります．