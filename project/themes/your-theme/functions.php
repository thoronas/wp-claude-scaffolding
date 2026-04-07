<?php
/**
 * Theme functions and definitions.
 *
 * @package YourTheme
 * @since   1.0.0
 */

declare( strict_types=1 );

// Autoload classes if Composer is used in the theme.
if ( file_exists( __DIR__ . '/vendor/autoload.php' ) ) {
	require_once __DIR__ . '/vendor/autoload.php';
}

// Include procedural files from inc/.
require_once __DIR__ . '/inc/setup.php';
// require_once __DIR__ . '/inc/enqueue.php';
// require_once __DIR__ . '/inc/template-tags.php';
// require_once __DIR__ . '/inc/block-patterns.php';
