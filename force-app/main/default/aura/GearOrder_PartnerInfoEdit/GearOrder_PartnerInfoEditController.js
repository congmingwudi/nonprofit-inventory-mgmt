({
    init: function(component, event, helper) {
        console.log('GearOrder_PartnerInfoEditController > init');
        
        // device form factor
        helper.getDeviceType(component);

        // load partner organization selection
        helper.getPartnerOrgSelection(component);
        
    }, // end init
    
	handleNavigation : function(component, event, helper) {
        
      var allGood = helper.validateFields(component);
      console.log('GearOrder_PartnerInfoEditController > handleNavigation - allGood: ' + allGood);
        
      if (allGood) {
          // fire stageChangedEvent - so that the wrapper lightning component around the flow will know the flow had advanced
          // this is used by the wrapper component to hide the product list component 
          var stageChangedEvent = component.getEvent("stageChangedEvent");
          stageChangedEvent.setParams({ "currentStageIndex": 1 }); // i used stage ordering in the flow beginning with index 0. so 1 is the second stage.
          stageChangedEvent.fire();          
          
          // set 'navigation' attribute that the flow will use to determine flow path
          var buttonClicked = event.getSource().getLocalId();
          component.set('v.navigation', buttonClicked);      
          console.log('GearOrder_PartnerInfoEditController > handleNavigation - clicked: ' + buttonClicked);
          
          // go forward in the flow; this does the same thing as the "Next" button in the standard flow footer      
          var navigate = component.get("v.navigateFlow");
          if (navigate) {
            navigate("NEXT");
          }          
      } 
            
   	}, // end handleNavigation
    
})