/**
 * Created by Abraham 
 */


$( "#atras" ).click(function() {
  goBack();
});
function goBack() {
    window.history.back();
}

$('#submit_button').click(function(){
	$("#form").submit();
	//return true;
});

$('#submit_button_global').click(function(){
    $(":input").each(function(){
			console.log( $(this));
			$("#fGlobal").append($(this)); // This is the jquery object of the input, do what you will
		});
    $("#fGlobal").submit();
});

