({
    init: function(component, event, helper) {
        console.log('GearOrder_PickupTimeController > init');        
		
        // load Gear Order
        var orderID = component.get("v.orderID");
        var orderName = component.get("v.orderName");
		helper.getGearOrder(component, orderID, orderName);
        
        // load picklist values
        helper.setPickupDates(component);
        helper.setPickupTimes(component);
        
        // test date picker
        //var today = new Date();
        //component.set('v.pickup_date1_date', today);
        
    }, // end init
     
    noTimesWorkChanged: function(component, event) {
        
        // set noTimesWork attribute - this is a workaround for value="{v.noTimesWork"} not updating the attribute for input type="checkbox"
        // noTimesWork also controls the 'disabled' attribute of the preferred dates and times
        var isChecked = component.find("noTimesWorkCheckbox").get("v.checked");        
        console.log('GearOrder_PickupTimeController > noTimesWorkChanged - isChecked: ' + isChecked);
		component.set("v.noTimesWork", isChecked);
         
	}, // end noTimesWork
    
	handleNavigation : function(component, event, helper) {
		
        // update pickup times in the GearOrder
        helper.setPickupDateTimes(component);
        
		var allGood = helper.validateFields(component);
      	console.log('GearOrder_PickupTimeController > handleNavigation - allGood: ' + allGood);
      
      	if (allGood) {           
            // set 'navigation' attribute that the flow will use to determine flow path
            var buttonClicked = event.getSource().getLocalId();
            component.set('v.navigation', buttonClicked);      
            console.log('GearOrder_PickupTimeController > handleNavigation - clicked: ' + buttonClicked);
          
            // go forward in the flow; this does the same thing as the "Next" button in the standard flow footer      
            var navigate = component.get("v.navigateFlow");
            if (navigate) {
                navigate("NEXT");      
            }
    	}
            
   	}, // end handleNavigation 

})