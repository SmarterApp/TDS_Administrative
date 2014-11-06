<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'ZxDStq4j');
define('DB_HOST', 'localhost');
define('SECRET_KEY', '8I8iNt8bWW2v71z76c6RptDuxeHOVxr1yDv3YNXqcz');

#This will disable the update notification.
define('WP_CORE_UPDATE', false);

$table_prefix  = 'wp_';
$server = DB_HOST;
$loginsql = DB_USER;
$passsql = DB_PASSWORD;
$base = DB_NAME;
$upload_path = "wp-content/uploads";
$upload_url_path = "http://portal-dev.opentestsystem.org/wp-content/uploads";
?>
