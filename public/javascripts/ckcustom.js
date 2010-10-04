CKEDITOR.editorConfig = function( config )
{
   CKEDITOR.config.PreserveSessionOnFileBrowser = true;
   //CKEDITOR.config.language = 'en';
   //CKEDITOR.config.extraPlugins = "embedvideo";

   CKEDITOR.config.toolbar_Easy =
    [
        ['Source'],
	    ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print' ],
	    ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
	    '/',
	    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
	    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
	    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
	    ['Link','Unlink','Anchor'],
	    ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
	    '/',
	    ['Styles','Format','Font','FontSize'],
	    ['TextColor','BGColor'],
	    ['Maximize', 'ShowBlocks','-','About']
    ];

	CKEDITOR.config.toolbar_CubelessImpl =
	[ 
		[ 'Bold','Italic', '-','SelectAll','Cut','Copy','Paste', '-',
		  'Subscript','Superscript', 
		  '-', 'Outdent','Indent','BulletedList', 'Blockquote', '-',
	      'JustifyLeft','JustifyCenter','JustifyRight',
	      'JustifyBlock','Maximize','-',  
	      'Source', 'About'],
	      '/',
	    [ 'Undo', 'Redo',  'Link', 'Unlink', '-',
	      'Image', 'Flash', 'embed', '-', 'Table',
		  'HorizontalRule','Smiley','-',  
		  'Find','Format'] 
    ];

 	CKEDITOR.config.toolbar_TheFullSink =
	[
	    ['Source','-','Save','NewPage','Preview','-','Templates'],
	    ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
	    ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
	    ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
	    '/',
	    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
	    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
	    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
	    ['Link','Unlink','Anchor'],
	    ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
	    '/',
	    ['Styles','Format','Font','FontSize'],
	    ['TextColor','BGColor'],
	    ['Maximize', 'ShowBlocks','-','About']
	];	
	
	CKEDITOR.config.toolbar = 'CubelessImpl';
	
};