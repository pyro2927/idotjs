# idotjs

[dotjs](https://github.com/defunkt/dotjs) for iOS. By storing .js files into your Dropbox folder `~/Dropbox/Apps/idotjs/`, you can inject Javascript into your mobile browsing experience.

## Javascript

idotjs uses [jQuery 1.8.2-minified](http://jquery.com/).  If any script is named `default.js`, it will load every time a page is loaded.

## Controls

### Shake

Shake-to-sync with your Dropbox account.

### Swipes

Swipe left/right to go back/forward in the webview.

### TabBar

Left/Right arrows move back/forward in the webview.  Action button to the right allows you to enter a specific web address.  Refresh button refreshes current page.

## Example

Drop this into `Apps/idotjs/github.com.js`:

	$('.header-logo-wordmark img').css('width', '97px').css('height', '80px').css('margin-top', '-15px').attr('src', '//bit.ly/ghD24e');
	
to get this

![sample](http://i.imgur.com/Klx5k.png).