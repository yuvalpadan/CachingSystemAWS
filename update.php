<?php
			
	# Set the time to use for the System.			
	date_default_timezone_set('Europe/London');
	
	# Set error print to enable
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
	
	# Get the Data from POST and see if key, data in correct format (500-8000 bytes), and expire was provided.
	# If the data is incorrect, send error message.
	if(!empty($_POST["key_vz"]) &&
		!empty($_POST["data_vz"]) &&
		strlen($_POST["data_vz"]) < 8000 &&
		strlen($_POST["data_vz"]) > 500 &&		
		!empty($_POST["expr_vz"]))
	{
	
		# Get the timestamp from the time provided to set expire time for the data.
		$timez = strtotime($_POST["expr_vz"]);
		
		# Create the array to use to add to the saved data file.
		$arrayAdd = array("data_v" => $_POST["data_vz"],"expr_v" => $_POST["expr_vz"]); 
		
		# Open the DB cache file for write to write the new data.
		$fp = fopen("/var/www/html/cachefile.dbcache", "r+");
		
		# Lock the file so it cannot get read while writing the same data (Race condition).
		if (flock($fp, LOCK_EX)) 
		{ 
			# Get the file contents.
			$objData = file_get_contents("/var/www/html/cachefile.dbcache"); 
			
			# Turn the data in the file to an object to inspect the saved data.
			$obj = unserialize($objData); 
			
			# Check if not found any data, then object is empty.
			if (empty($obj))
			{
				$obj = array();
			}
			
			# Set new data in the save object.
			$obj[$_POST["key_vz"]] = $arrayAdd; 
			
			# Turn back the save object to save to file.
			$objdatav = serialize($obj); 
			
			# Write the save object string to the file.
			fwrite($fp,$objdatav);
			fflush($fp); 
			
			# Finished read, release lock so other processes can write.
			flock($fp, LOCK_UN); 
		}
		
		# Close the file.
		fclose($fp);
		
		# Print message that the data was added.
		echo("Added");
	}
	else
	{
		# Send error message.
		http_response_code(400);
		echo json_encode(array("message" => "Invalid Data"));
	}
?>
