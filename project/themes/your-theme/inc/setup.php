<?php
/**
 * Theme setup.
 *
 * @package YourTheme
 * @since   1.0.0
 */

declare( strict_types=1 );

/**
 * Sets up theme defaults and registers support for various WordPress features.
 *
 * @since 1.0.0
 *
 * @return void
 */
function your_theme_setup(): void {
	// Add support for block styles.
	add_theme_support( 'wp-block-styles' );

	// Enqueue editor styles.
	add_editor_style( 'assets/css/editor.css' );
}
add_action( 'after_setup_theme', 'your_theme_setup' );

/**
 * Enqueue theme styles and scripts.
 *
 * @since 1.0.0
 *
 * @return void
 */
function your_theme_enqueue_assets(): void {
	wp_enqueue_style(
		'your-theme-style',
		get_stylesheet_uri(),
		[],
		wp_get_theme()->get( 'Version' )
	);
}
add_action( 'wp_enqueue_scripts', 'your_theme_enqueue_assets' );
