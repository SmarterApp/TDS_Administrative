<?php
/***
 * WordPress's Debianised default master config file
 * Please do NOT edit and learn how the configuration works in
 * /usr/share/doc/wordpress/README.Debian
 ***/

/* Look up a host-specific config file in
 * /etc/wordpress/config-<host>.php or /etc/wordpress/config-<domain>.php
 */
$debian_server = preg_replace('/:.*/', "", $_SERVER['HTTP_HOST']);
$debian_server = preg_replace("/[^a-zA-Z0-9.\-]/", "", $debian_server);
$debian_file = '/etc/wordpress/config-'.strtolower($debian_server).'.php';
/* Main site in case of multisite with subdomains */
$debian_main_server = preg_replace("/^[^.]*\./", "", $debian_server);
$debian_main_file = '/etc/wordpress/config-'.strtolower($debian_main_server).'.php';

if (file_exists($debian_file)) {
    require_once($debian_file);
    define('DEBIAN_FILE', $debian_file);
} elseif (file_exists($debian_main_file)) {
    require_once($debian_main_file);
    define('DEBIAN_FILE', $debian_main_file);
} elseif (file_exists("/etc/wordpress/config-default.php")) {
    require_once("/etc/wordpress/config-default.php");
    define('DEBIAN_FILE', "/etc/wordpress/config-default.php");
} else {
    header("HTTP/1.0 404 Not Found");
    echo "Neither <b>$debian_file</b> nor <b>$debian_main_file</b> could be found. <br/> Ensure one of them exists, is readable by the webserver and contains the right password/username.";
    exit(1);
}

/* Default value for some constants if they have not yet been set
   by the host-specific config files */
define('ABSPATH', '/usr/share/wordpress/');
define('WP_CORE_UPDATE', false);
define('WP_ALLOW_MULTISITE', true);
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_HOST', 'localhost');
define('WP_HOME','http://portal-dev.opentestsystem.org');
define('WP_SITEURL','http://portal-dev.opentestsystem.org');

/* WP Secret Key defines */
/* From https://api.wordpress.org/secret-key/1.1/salt/ */
define('AUTH_KEY',         '=#0vfC^?^&<=*M{|!X|gB0*/%C7>/x++ zW-|.!4A+l0~}5yf1L7Q.Xd?q}|:O@7');
define('SECURE_AUTH_KEY',  ' oZ1{7^(x`}Ot)yZYU+mikN}Iib aM.su:zw8J$X*V.YX+C|i&6`$B4ECqMr .+{');
define('LOGGED_IN_KEY',    '5%F@RZX_:4r-h#(Xh-.UY}.G8fZFU~GR`~@J7m&IB!9{QG-+|F%^]g0BDzK/$n=|');
define('NONCE_KEY',        '7$(j_MT:;CxFd[]2yBV%2m|*:t8-==hSxU# ]e@f#lJUWu@Px18|9u1tL5t)d*}4');
define('AUTH_SALT',        '^6A%=f&,7PY]TLqXivozK:qLn^v/5p?a/0!KSBQzJGw.e=uQl|0G$13j`Cdt*`JF');
define('SECURE_AUTH_SALT', 'l4QBw3h-2,mh(5+ri=s-sOX(|-xRM&2@;6=EY*9ekspc>)^5+d7.NTjFkxc0YKKP');
define('LOGGED_IN_SALT',   'je-|Hd_B;ouCXdIDD2v!YljVe-/;9(]tR/Vxe-*wrH|g/LzcZk#uf#/.:GeO0Q.g');
define('NONCE_SALT',       'W,|2SM/_ L8QK+$VFd$M{*v:[n$:W,:l-`Y2wU!T{DD _(L,n-7+)(4,szsK>R}O');


/* Default value for the table_prefix variable so that it doesn't need to
   be put in every host-specific config file */
if (!isset($table_prefix)) {
    $table_prefix = 'wp_';
}

//$method = 'direct'; // stops the FTP details screen from appearing 
define(‘FS_METHOD’,’direct’); // Trying to stop FTP details screen from appearing 

require_once(ABSPATH . 'wp-settings.php');
?>
