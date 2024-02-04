<?php
// PHP code just started

$dataPoints = array();
$show = true;
ini_set('error_reporting', E_ALL);
ini_set('display_errors', true);
// display errors

$db = mysqli_connect("dbase.cs.jhu.edu", "23fa_urawat1", "jU8XE6RM7p");

if (!$db) {
    echo "Connection failed!";
    $show = false;
} else {
    

    mysqli_select_db($db, "23fa_urawat1_db");

    $result = mysqli_query($db, "CALL D1()");
    // call to procedure

    if (!$result || $result->num_rows == 0) {
        echo "No results.\n";
        $show = false;
    } else {
        echo "<table style='border-collapse: collapse; width: 80%; margin: 20px auto;'>\n";
        echo "<tr><th>First Name</th><th>Last Name</th></tr>\n";
        while ($myrow = mysqli_fetch_array($result)) {
            printf("<tr>
                <td>%s</td>
                <td>%s</td></tr>\n",
                $myrow["firstName"], $myrow["lastName"]);
        }
    }
    echo "</table>\n";
}

// PHP code about to end
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>First Name vs Last Name</title>

    <!-- Include Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            font-family: 'Arial', sans-serif;
        }

        table {
            border-collapse: collapse;
            width: 80%;
            margin: 20px auto;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
        }

        canvas {
            display: block;
            margin: 20px auto; 
        }
    </style>
</head>


</html>
