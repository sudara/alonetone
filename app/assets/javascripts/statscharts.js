
$('#expand-charts').on('click', function(event) {
	event.preventDefault();
	$('.panel-body').removeClass('hide');
	$('.panel-body').siblings('.toggle-chart').html('-');
});

$('#collapse-charts').on('click', function(event) {
	event.preventDefault();
	$('.panel-body').addClass('hide');
	$('.panel-body').siblings('.toggle-chart').html('+');
});

$('.toggle-chart').on('click', function(event) {
	event.preventDefault();
	$(this).parents('.panel-heading').siblings('.panel-body').toggleClass('hide');
	$(this).html($(this).text() == '-' ? '+' : '-');
});