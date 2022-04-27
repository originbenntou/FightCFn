<?php

$survives = explode(" ", trim(fgets(STDIN))); // 生き残り
$capacity = intval(trim(fgets(STDIN))); // ボート空き容量

$resqueState = [
    "survives" => $survives,
    "boatCapacity" => $capacity,
    "riders" => [],
    "remains" => []
];

// 体重降順
// 一番重い人がボートに乗れなければ確実に「ピンチ！」
// そうじゃなければ全員脱出できる
rsort($survives);

if (max($survives) > $capacity) {
    echo "ピンチ！" . "\n";
} else {
    echo resqueAttempt($resqueState, 0) . "\n";
}

/*
 * 救助施行
 * 出航回数＝ボートの数を返却
 */
function resqueAttempt($resqueState, $sailCount = 0) {
    // 再帰関数ストッパー
    // 生き残りがいなくなるまで再帰呼び出しが続く
    if (count($resqueState["survives"]) === 0) {

        // ボードに誰か乗っていたら出航
        if (count($resqueState["riders"]) > 0) {
            $resqueState = sail($resqueState);
            $sailCount++;
        }

        // 居残りがまだ入れば救助は完了していない
        // 再実行
        if (count($resqueState["remains"]) > 0) {
            $resqueState = reRescue($resqueState);
            return resqueAttempt($resqueState, $sailCount);
        }

        // 生き残りがいない、居残りもいないなら救助完了
        return $sailCount;
    }

    // ボートの空き容量が最も少なくなるように計算
    // まず生き残りの中でいちばん重い人からボートに乗る
    $survive = array_shift($resqueState["survives"]);

    // 体重を測ってボートに乗る
    // 乗れなかったら居残り
    if ($survive <= $resqueState["boatCapacity"]) {
        $resqueState = ride($resqueState, $survive);
    } else {
        $resqueState = remain($resqueState, $survive);
    }

    // 再帰呼び出し
    return resqueAttempt($resqueState, $sailCount);
}

// 救助状態を操作する関数群

/*
 * ライド
 * 生き残りをボートに移動して、ボートの空き容量を減らす
 */
function ride($resqueState, $survive): array
{
    $resqueState["boatCapacity"] = $resqueState["boatCapacity"] - $survive;
    $resqueState["riders"][] = $survive;

    return $resqueState;
}


/*
 * 居残り
 * 生き残りを居残り組に移動する
 */
function remain($resqueState, $survive): array
{
    $resqueState["remains"][] = $survive;

    return $resqueState;
}

/*
 * 出航
 * ボートの空き容量と乗っている人をもとに戻して、新しいボートの状態にする
 */
function sail($resqueState): array
{
    $resqueState["boatCapacity"] = array_sum($resqueState["riders"]) + $resqueState["boatCapacity"];
    $resqueState["riders"] = [];

    return $resqueState;
}

/*
 * 再救助
 * 居残り組を再度生き残りにする
 */
function reRescue($resqueState): array
{
    $resqueState["survives"] = $resqueState["remains"];
    $resqueState["remains"] = [];

    return $resqueState;
}
