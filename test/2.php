<?php

// 茶色と緑の格子数
[$brown, $green] = explode(" ", trim(fgets(STDIN)));

// 緑格子を四角形に並べたとき縦横それぞれの枚数をペアにしてリスト
// 緑格子の縦が1枚,2枚...と増やしていき、横の枚数を算出
// 縦横の組み合わせはどこかで繰り返しになるため、縦の枚数を増やすのは合計枚数の平方根まで
$greenRowColumn = [];
for ($i = 1; $i <= sqrt($green); $i++) {
    if (($green % $i) === 0) {
        $greenRowColumn[] = [$i, $green / $i];
    }
}

$answer = [];
foreach ($greenRowColumn as $queue) {
    [$greenRow, $greenColumn] = $queue;
    $sum = $green + $brown;

    // 茶色格子は緑格子を囲むように並べる
    // 四角形になるように並べるので縦列×横列が格子の合計となる、2重ループでそれを見つける
    // 縦格子を増やせる最大は、格子の合計を横格子の枚数（最小）で割った商
    // 横格子を増やせる最大は、格子の合計を縦格子の枚数で割った商
    // 商のあまりが出る場合、縦×横=合計枚数にはならないので無視できる
    for ($i = $greenRow + 2; $i <= floor($sum / ($greenColumn + 2)); $i = $i + 2) {
        for ($j = $greenColumn + 2; $j <= floor($sum / $i); $j = $j + 2) {
            if (($i * $j) == $sum) {
                $answer = [$i, $j];
                break;
            }
        }
    }

}

if (count($answer) === 0) {
    echo "記憶違い！" . "\n";
} else {
    rsort($answer);
    echo implode(",", $answer) . "\n";
}

