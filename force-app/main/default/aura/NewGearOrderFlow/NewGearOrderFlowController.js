({
    init: function(component, event, helper) {
        console.log('NewGearOrderFlowController > init');
        
        var flowName = "New_Gear_Order";
        
        // find the view component (by aura:id) where the flow will be displayed
        var flow = component.find(flowName);
        
        // start the flow by the flow Unique Name
        flow.startFlow(flowName);
    }, // end init
    
    handleStageChangedEvent : function(component, event, helper) {
        
        console.log('NewGearOrderFlowController > handleStageChangedEvent');
        var currentStageIndex = event.getParam("currentStageIndex");
        component.set('v.currentStageIndex', currentStageIndex);
        console.log('NewGearOrderFlowController > handleStageChangedEvent - currentStageIndex: ' + currentStageIndex); 
        
    } // end handleStageChangedEvent
    
    /* not used yet, because the currentStage received isn't being updated from the flow as it should
    flowStatusChange : function (component, event) {
        
        // outputVariables
    	var outputVariables = event.getParam('outputVariables');
        console.log("NewGearOrderFlowController > flowStatusChange - outputVariables: " + JSON.stringify(outputVariables));

        // activeStages
    	var activeStages = event.getParam('activeStages');
        console.log("NewGearOrderFlowController > flowStatusChange - activeStages: " + JSON.stringify(activeStages));
        
        // currentStage 
        var currentStage = event.getParam('currentStage');
        console.log("NewGearOrderFlowController > flowStatusChange - currentStage: " + JSON.stringify(currentStage));		
        
  	}, // end flowStatusChange
    */
})