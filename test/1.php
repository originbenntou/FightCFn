<?php

$survives = explode(" ", trim(fgets(STDIN)));
$capacity = intval(trim(fgets(STDIN)));

rsort($survives);

$resqueState = [
    "survives" => $survives,
    "boatCapacity" => $capacity,
    "riders" => [],
    "remains" => []
];

if (max($survives) > $capacity) {
    echo "ピンチ！" . "\n";
} else {
    echo resqueAttempt($resqueState, 0) . "\n";
}

function resqueAttempt($resqueState, $sailCount = 0) {
    if (count($resqueState["survives"]) === 0) {

        if (count($resqueState["riders"]) > 0) {
            $resqueState = sail($resqueState);
            $sailCount++;
        }

        if (count($resqueState["remains"]) > 0) {
            $resqueState = reRescue($resqueState);
            return resqueAttempt($resqueState, $sailCount);
        }

        return $sailCount;
    }

    $survive = array_shift($resqueState["survives"]);

    if ($survive <= $resqueState["boatCapacity"]) {
        $resqueState = ride($resqueState, $survive);
    } else {
        $resqueState = remain($resqueState, $survive);
    }

    return resqueAttempt($resqueState, $sailCount);
}

function ride($resqueState, $survive) {
    $resqueState["boatCapacity"] = $resqueState["boatCapacity"] - $survive;
    $resqueState["riders"][] = $survive;

    return $resqueState;
}

function remain($resqueState, $survive) {
    $resqueState["remains"][] = $survive;

    return $resqueState;
}

function sail($resqueState) {
    $resqueState["boatCapacity"] = array_sum($resqueState["riders"]) + $resqueState["boatCapacity"];
    $resqueState["riders"] = [];

    return $resqueState;
}

function reRescue($resqueState) {
    $resqueState["survives"] = $resqueState["remains"];
    $resqueState["remains"] = [];

    return $resqueState;
}
