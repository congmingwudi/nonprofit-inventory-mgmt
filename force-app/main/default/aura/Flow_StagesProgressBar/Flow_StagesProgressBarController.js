({
    
	init : function(component, event, helper) {
        
        var stages = component.get('v.stages');
        var currentStageIndex = component.get('v.currentStageIndex');
        
        // set currentStage
        var currentStage = stages[currentStageIndex];
        component.set('v.currentStage', currentStage);
        
      	var progressIndicator = component.find('progressIndicator');
       
      	for (let step of component.get('v.stages')) {
         	$A.createComponent(
            	"lightning:progressStep",
             	{
               	"aura:id": "step_" + step,
               	"label": step,
               	"value": step
             	},
             	function(newProgressStep, status, errorMessage){
                	// Add the new step to the progress array
                	if (status === "SUCCESS") {
                   		var body = progressIndicator.get("v.body");
                   		body.push(newProgressStep);
                   		progressIndicator.set("v.body", body);
                 	} else if (status === "INCOMPLETE") {
                    	// Show offline error
                    	console.log("Flow_ProgressBarController > init - no response from server, or client is offline.")
                  	} else if (status === "ERROR") {
                     // Show error message
                     console.log("Flow_ProgressBarController > init - error: " + errorMessage);
                  	}
              	}
           	); // end create component
       	} // end for stages
       
   } // end init
    
})