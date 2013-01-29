(function()
{
	// The pastetext command definition.
	var embedCmd =
	{
		exec : function( editor )
		{
		  editor.openDialog( 'embed' );
		  return;
		}
	};
  
	// Register the plugin.
	CKEDITOR.plugins.add( 'embed',
	{
	  lang : [ 'en', 'ru', 'uk' ],
	  requires : [ 'dialog' ],
	  
		init : function( editor )
		{ 
			var commandName = 'embed';
			editor.addCommand( commandName, embedCmd );
      
			editor.ui.addButton( 'embed',
				{
					label : editor.lang.embed.button,
					command : commandName,
					icon: this.path + "images/embed.png"
				});
      
			CKEDITOR.dialog.add( commandName, CKEDITOR.getUrl( this.path + 'dialogs/embed.js' ) );
		}
	});
	
})();
