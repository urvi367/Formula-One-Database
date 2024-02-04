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
 
  $input = $_POST['raceID'];
  if ($input == "select") 
    {
      echo "Invalid race!\n";
      exit();
    }

  mysqli_select_db($db, "23fa_urawat1_db");

  $result = mysqli_query($db, "CALL A1('".$input."')");
  // call to procedure

  if (!$result || $result->num_rows == 0) {
    echo "No results.\n";
    $show = false;

  } else {
    echo "<table border=1 style='margin: 0 auto;'>\n";
    echo "<tr><td>Race</td><td>Race Year</td><td>Driver Name</td><td>Final Position</td><td>Incident Description</td><td>Fastest Lap Time</td></tr>\n";
    while ($myrow = mysqli_fetch_array($result)) {
        printf("<tr>
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                <td>%s</td>
                </tr>\n", 
        $myrow["Race"], $myrow["RaceYear"], $myrow["DriverName"], $myrow["finalPosition"], $myrow["IncidentDescription"], $myrow["fastestLapTime"]);
    }
  }
    echo "</table>\n";
}

// PHP code about to end

?>