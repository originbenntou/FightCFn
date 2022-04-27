<?php

[$brown, $green] = explode(" ", trim(fgets(STDIN)));

$greenRowColumn = [];

for ($i = 1; $i <= sqrt($green); $i++) {
    if (($green % $i) === 0) {
        $greenRowColumn[] = [$i, $green / $i];
    }
}

$answer = [];
foreach ($greenRowColumn as $queue) {
    [$row, $column] = $queue;

    for ($i = $row + 2; $i <= floor($brown + $green / ($column + 2)); $i = $i + 2) {
        for ($j = $column + 2; $j <= floor($brown + $green / $i); $j = $j + 2) {
            if ((($i * $j) - $green) == $brown) {
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

