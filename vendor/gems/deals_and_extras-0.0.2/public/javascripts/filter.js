$(function() {
	// DH: Uncheck the includes section of the filter
	$('#filter_uncheck_all').click(function(){
		$('#filter_includes > input').attr('checked',false);
	});

	// DH: Clear all the filter fields and boxes
	$('#filter_clear_search').click(function(){
		$('#filter_includes > input').attr('checked',false);
		$('#filter_origin option[value=none]').attr('selected', 'selected');
		$('#filter_destination option[value=none]').attr('selected', 'selected');
		$('#filter_dates input').attr('checked',false);
	});

    $('#filterSearchButton').click(function(e){
        e.preventDefault();
        // go to the first page of the new search results
        $(window).trigger('agentstream:filterSearch', 1);
    });
   
    
    $("#start_date").datepicker();
    $("#end_date").datepicker();

});