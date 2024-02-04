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

  $input = $_POST['circuitid'];
  if ($input == "select") 
    {
      echo "Invalid circuit!\n";
      exit();
    }
  

  mysqli_select_db($db, "23fa_urawat1_db");
  

  $result = mysqli_query($db, "CALL C2('".$input."')");
  // call to procedure

  if (!$result || $result->num_rows == 0) {
    echo "No results.\n";
    $show = false;

  } else {
    echo "<table border=1 style='margin: 0 auto;'>\n";
    echo "<tr><td>Constructor Name</td><td>Average Points</td></tr>\n";
    while ($myrow = mysqli_fetch_array($result)) {
        printf("<tr>
                <td>%s</td>
                <td>%s</td>
                </tr>\n", 
        $myrow["ConstructorName"], $myrow["AveragePoints"]);
    }
  }
    echo "</table>\n";
}

// PHP code about to end

?>