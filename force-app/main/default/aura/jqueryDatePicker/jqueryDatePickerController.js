({    
	init : function(component, event, helper) {
		console.log('jqueryDatePickerController > scripts loaded');         
        console.log('jqueryDatePickerController > jquery_ui_lib: ' + component.get("v.jquery_ui_lib"));
        
        if (typeof jQuery == 'function') {
            
            jQuery("document").ready(function(){
                console.log('jqueryDatePickerController > init - jquery loaded');

                var datePickerID = component.get("v.datePickerID");                
                var dateString = component.get("v.dateString");
                console.log('jqueryDatePickerController > init - datePickerID: ' + datePickerID + ', dateString: ' + JSON.stringify(dateString));
                
                // show date picker
                $('#' + datePickerID).datepicker({
                    onClose : function( dateText, instance ) {
                        console.log('jqueryDatePickerController > init - onClose');
                    }
                }).datepicker('setDate', dateString).datepicker('show');
                 
            }); // end jQuery   
        }
        
	}, // end init  

    dateChanged : function(component, event, helper) {  
        
        if (typeof jQuery == 'function') {
            console.log('jqueryDatePickerController > dateChanged - jQuery is available');
            
            var datePickerID = component.get("v.datePickerID");                
            var dateString = component.get("v.dateString");
            console.log('jqueryDatePickerController > init - datePickerID: ' + datePickerID + ', dateString: ' + JSON.stringify(dateString));

            // show date picker
            jQuery($('#' + datePickerID)).datepicker().datepicker('setDate', dateString).datepicker('show');
        }       
        
    }, // end dateChanged
    
})