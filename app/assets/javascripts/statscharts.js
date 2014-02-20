// hide all charts
$('#collapse-charts').on('click', function(event) {
	event.preventDefault();

	// hide all the cool shit
	$('.panel-body').addClass('hide');
	$('.toggle-chart').html('+');

	// hide this button and show the other
	$(this).addClass('hide');
	$('#expand-charts').removeClass('hide');
});

// show all charts
$('#expand-charts').on('click', function(event) {
	event.preventDefault();

	// make the cool shit show up
	$('.panel-body').removeClass('hide');
	$('.toggle-chart').html('-');

	// hide this button and show the other
	$(this).addClass('hide');
	$('#collapse-charts').removeClass('hide');
});

// toggle hide/show for individual charts
$('.toggle-chart').on('click', function(event) {
	event.preventDefault();
	$(this).parents('.panel-heading').siblings('.panel-body').toggleClass('hide');
	$(this).html($(this).text() == '-' ? '+' : '-');
});