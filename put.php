<?php

	# Set the time to use for the System.	
	date_default_timezone_set('Europe/London');
	
	# Set error print to enable
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
	
	# Get the Json Data from POST and decode it to inspect it.
	$data = json_decode(file_get_contents("php://input"));
	
	# Get the Data from POST Json data and see if key, data in correct format (500-8000 bytes), and expire was provided.
	if(!empty($data->str_key) &&
		!empty($data->data) &&
		strlen($data->data) < 8000 &&
		strlen($data->data) > 500 &&		
		!empty($data->expiration_date))
	{
		# Get the timestamp from the time provided to set expire time for the data.
		$timez = strtotime($data->expiration_date);
		
		# Create the array to use to add to the saved data file.
		$data = array("expr_vz" => $timez, "key_vz" => $data->str_key , "data_vz" => $data->data); 
		
		# Prepare a POST to send to other nodes to Sync them with the new data.
		$options = array( 
					"http" => 
					array( "header"  => "Content-type: application/x-www-form-urlencoded",
						   "method"  => "POST",
						   "content" => http_build_query($data)));
		$context  = stream_context_create($options); 
		
		# Get a list of the nodes the are in the load balancer - The script returns using the aws command the DNS of the nodes.
		$getpd = shell_exec("/var/www/listDNSCacheInstances.sh"); 
		
		# Turn the list to an array.
		$pdList = explode(PHP_EOL, $getpd);
		
		# Foreach DNS in the array.
		foreach ($pdList as &$value) 
		{
			# If the DNS is valid.
			if (!empty($value)) 
			{
				# Setup the URL to activate.
				$url = "http://" . $value . "/update.php";
				
				# Send the POST request.
				file_get_contents($url, false, $context); 
			}
		}
		
		# Print message that the data was added.
		echo("Completed");
	}
	else
	{
		# Send error message.
		http_response_code(400);
		echo json_encode(array("message" => "Invalid Data"));
	}
?>
