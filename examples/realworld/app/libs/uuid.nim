import times
import random
import strformat

proc genUuid*(): string =
  var uuid = newSeq[uint8](16)

  # 現在のタイムスタンプをミリ秒単位で取得
  let nowMs = int64(epochTime() * 1000)

  # タイムスタンプを最初の6バイトに設定
  for i in 0..5:
    uuid[i] = uint8((nowMs shr (8 * (5 - i))) and 0xFF)

  # 12ビットのランダムデータを生成
  let rand12 = rand(1 shl 12)  # 0から4095までのランダム値

  # uuid[6]の設定：バージョン（7）とランダムデータの上位4ビット
  uuid[6] = uint8(((rand12 shr 8) and 0x0F) or 0x70)  # 0x70はバージョン7を示す

  # uuid[7]の設定：ランダムデータの下位8ビット
  uuid[7] = uint8(rand12 and 0xFF)

  # uuid[8]の設定：バリアントビット（'10'）とランダムデータ
  let rand8 = rand(256)
  uuid[8] = uint8((rand8 and 0x3F) or 0x80)  # 0x80でビット7を1に設定

  # 残りのバイトをランダムデータで埋める
  for i in 9..15:
    uuid[i] = uint8(rand(256))

  # UUIDを文字列形式に変換
  result = ""
  for i in 0..15:
    result &= &"{uuid[i]:02x}"
    if i == 3 or i == 5 or i == 7 or i == 9:
      result &= "-"
