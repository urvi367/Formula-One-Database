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

    $result = mysqli_query($db, "CALL D2()");
    // call to procedure

    if (!$result || $result->num_rows == 0) {
        echo "No results.\n";
        $show = false;
    } else {
        // Collect data points for Chart.js
        while ($myrow = mysqli_fetch_array($result)) {
            $dataPoints[] = array(
                "nationality" => $myrow["nationality"],
                "numDrivers" => $myrow["numDrivers"],
                "averagePoints" => $myrow["AveragePointsPerSeason"]
            );
        }

        // Sort data points by average points in descending order
        usort($dataPoints, function ($a, $b) {
            return $b['averagePoints'] <=> $a['averagePoints'];
        });
    }
}

// PHP code about to end
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nationality vs Average Points</title>

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

<body>

    <?php
    if ($show) {
        echo "<table>\n";
        echo "<tr><th>Nationality</th><th>Number of Drivers</th><th>Average Points Per Season</th></tr>\n";
        foreach ($dataPoints as $dataPoint) {
            printf("<tr>
                    <td>%s</td>
                    <td>%s</td>
                    <td>%s</td></tr>\n",
                $dataPoint["nationality"], $dataPoint["numDrivers"], $dataPoint["averagePoints"]);
        }
        echo "</table>\n";
    }
    ?>

    <!-- Create a canvas for the Chart.js chart -->
    <canvas id="nationalityChart" width="800" height="400"></canvas>

    <script>
        // Use Chart.js to create a bar chart
        var ctx = document.getElementById('nationalityChart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: <?php echo json_encode(array_column($dataPoints, 'nationality')); ?>,
                datasets: [{
                    label: 'Average Points Per Season',
                    data: <?php echo json_encode(array_column($dataPoints, 'averagePoints')); ?>,
                    backgroundColor: 'rgba(75, 192, 192, 0.2)', 
                    borderColor: 'rgba(75, 192, 192, 1)', 
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    x: {
                        type: 'category',
                        labels: <?php echo json_encode(array_column($dataPoints, 'nationality')); ?>,
                        title: {
                            display: true,
                            text: 'Driver Nationality'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Average Points Per Season'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                }
            }
        });
    </script>

</body>

</html>
