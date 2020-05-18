({
    init: function(component, event, helper) {
        
        console.log('GearOrder_ItemsEditController > init'); 
        
        // load Gear Order
        var orderID = component.get("v.orderID");
        var orderName = component.get("v.orderName");
        helper.getGearOrder(component, orderID, orderName);

    }, // end init

	handleNavigation : function(component, event, helper) {
        
    	// fire stageChangedEvent - so that the wrapper lightning component around the flow will know the flow had advanced
    	// this is used by the wrapper component to hide the product list component 
    	var stageChangedEvent = component.getEvent("stageChangedEvent");
     	stageChangedEvent.setParams({ "currentStageIndex": 0 }); // i used stage ordering in the flow beginning with index 0. so 0 is the first stage.
      	stageChangedEvent.fire(); 
      
      	// set 'navigation' attribute that the flow will use to determine flow path
      	var buttonClicked = event.getSource().getLocalId();
      	component.set('v.navigation', buttonClicked);      
      	console.log('GearOrder_SubmittedController > handleNavigation - clicked: ' + buttonClicked);
      
      	// go forward in the flow; this does the same thing as the "Finish" button in the standard flow footer      
      	var navigate = component.get("v.navigateFlow");
      	if (navigate) {
      		navigate("FINISH");      
      	}
            
   	}, // end handleNavigation     
    
})