$(function() {
	$('#nav_map').click(function(e) {
		switchToMapView();
	});
	
	$('#nav_list').click(function(e) {	
		switchToListView();
	});

	$('#nav_my_folder').click(function(e) {
		switchToMyFolder();
	});
	
	$('#nav_search').click(function(e) {
		switchToSearch();
	});

	$('#nav_list').addClass('listMap-selected');
	$('#nav_search').addClass('nav-tab-nav-selected');

});

var last_folder = []
var last_search = [];
// function loadMap(){
//     // come back and clean this up
//     // big time
//     
//     alert('LOADING MAP');
// 
//     var b;
//     if(isInSearchState()){
//       alert('Search State');
//         b = $('button[class=add_remove_folder]')
//     }else{
//       alert('No Search State')
//         b = $('button[class=remove_from_favorites]')
//     }
//     
//     var offer_ids = "";
//     for(var i = 0; i < b.length; i++){
//         offer_ids += b[i].value + ","
//     }
// 
//     if(offer_ids == ""){
//         if(isInSearchState()){
//             offer_ids = last_folder
//         }else{
//             offer_ids = last_search
//         }
//     }
// 
//     if(isInSearchState()){
//         last_search = offer_ids
//     }else{
//         last_folder = offer_ids
//     }
//     
//     alert(offer_ids);
//     
//     $('#contentContainer').html("").load("maps/" + offer_ids);
// }

function loadMap(){
    var b;
    if(isInSearchState()){
        b = $('.add_remove_folder');
    }else{
        b = $('.remove_from_favorites')
    }
    
    var offer_ids = "";
    for(var i = 0; i < b.length; i++){
      $b = $(b[i]).parent().parent();
      id = $b.attr('action').replace("/favorites?id=","");
      offer_ids += id + ","
    }

    if(offer_ids == ""){
        if(isInSearchState()){
            offer_ids = last_folder
        }else{
            offer_ids = last_search
        }
    }

    if(isInSearchState()){
        last_search = offer_ids
    }else{
        last_folder = offer_ids
    }
    
    $('#contentContainer').html("").load("/maps?p=" + offer_ids);
}

function switchToMapView() {
    loadMap();
    $('#nav_list').removeClass('listMap-selected');
    $('#nav_map').addClass('listMap-selected');
}


function switchToListView() {
    if (isInSearchState()){
        $(window).trigger('agentstream:filterSearch');
    }else{
        $('#contentContainer').html("").load("favorites");
    }
    $('#nav_map').removeClass('listMap-selected');
    $('#nav_list').addClass('listMap-selected');

}

function switchToSearch() {
    if (isInListState()){
        $('#contentContainer').html("");
        $(window).trigger('agentstream:filterSearch');
    }else{
        loadMap();
    }

    $('#rightContent').removeClass('dealTableFullScreen');
    $('#rightContent').addClass('dealTablePartial');

    $('#filter').show(200);
    $('#removeAll').hide();
    $('#downloadToPDF').hide();

	$('#nav_search').addClass('nav-tab-nav-selected');
	$('#nav_my_folder').removeClass('nav-tab-nav-selected');
}

function switchToMyFolder() {
    if (isInListState()){
        $('#contentContainer').html("").load("favorites");
    }else{
        loadMap();
    }

    $('#rightContent').removeClass('dealTablePartial');
    $('#rightContent').addClass('dealTableFullScreen');

    $('#filter').hide(200);
    $('#removeAll').show();
    $('#downloadToPDF').show();

    $('#nav_my_folder').addClass('nav-tab-nav-selected');
    $('#nav_search').removeClass('nav-tab-nav-selected');

}

function isInSearchState()
{
	return $('#nav_search').hasClass('nav-tab-nav-selected');
}

function isInListState()
{
	return $('#nav_list').hasClass('listMap-selected');
}