<?php
/**
 * Plugin Name: Your Plugin
 * Plugin URI:  https://example.com
 * Description: A custom plugin.
 * Version:     1.0.0
 * Requires at least: 6.6
 * Requires PHP: 8.1
 * Author:      Your Name
 * Author URI:  https://example.com
 * License:     GPL-2.0-or-later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: your-plugin
 * Domain Path: /languages
 *
 * @package YourPlugin
 */

declare( strict_types=1 );

// Prevent direct access.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// Plugin constants.
define( 'YOUR_PLUGIN_VERSION', '1.0.0' );
define( 'YOUR_PLUGIN_FILE', __FILE__ );
define( 'YOUR_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'YOUR_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

// Autoload via Composer (from repo root).
// If running Composer at the repo root (wp-content level), the autoloader
// is at the repo root's vendor/. If the plugin has its own composer.json,
// adjust the path accordingly.
$autoloader = dirname( __DIR__, 2 ) . '/vendor/autoload.php';
if ( file_exists( $autoloader ) ) {
	require_once $autoloader;
}

// Bootstrap the plugin.
// require_once __DIR__ . '/src/bootstrap.php';
