<?php
	# Set the time to use for the System.
	date_default_timezone_set('Europe/London');
	
	# Set error print to enable
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
	
	# Get the Json Data from POST and decode it to inspect it.
	$data = json_decode(file_get_contents("php://input"));
	
	# Check if the key used to get the data is defined
    if(empty($data->str_key))
	{
		# The key is not found - exit with error.
		http_response_code(400);
		echo json_encode(array("message" => "Invalid Data"));
	}
	else
	{
		# Get the current time and data timestamp.
		$timenow = strtotime("now");
		
		# Open the DB cache file for read to get the info.
		$fp = fopen("/var/www/html/cachefile.dbcache", "r");
		
		# Lock the file so it cannot get written while getting the saved data.
		if (flock($fp, LOCK_EX)) 
		{ 
			# Get the file contents.
			$objData = file_get_contents("/var/www/html/cachefile.dbcache"); 
			
			# Finished read, release lock so other processes can write.
			flock($fp, LOCK_UN); 
			
			# Close the file.
			fclose($fp);
			
			# Turn the data in the file to an object to inspect the saved data.
			$obj = unserialize($objData); 
			
			# Check if not found any data, then object is empty.
			if (empty($obj))
			{ 
				$obj = array(); 
			} 
		} 
		
		
		
		# Check if there's data for the used key.
		if (isset($obj[$data->str_key])) 
		{ 
			# Get the data for the key.
			$objcz = $obj[$data->str_key];
			
			# Pull the expire time of the data.
			$exp_time = $objcz["expr_v"];
			
			# Check if the data isn't expired.
			if ($exp_time >= $timenow) 
			{
				# The data isn't expired, print the data.
				$data_vd = $objcz["data_v"]; 
				echo $data_vd;
			} 
		}
	}
?>
