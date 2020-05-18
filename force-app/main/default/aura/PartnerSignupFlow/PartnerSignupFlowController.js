/**
 * Created by ryan.cox on 2019-09-18.
 */

({

   init: function(component, event, helper) {

        var flowName = "Partner_Signup";
        console.log('PartnerSignupFlowController > init - flowName: ' + flowName);

        // find the view component (by aura:id) where the flow will be displayed
        var flow = component.find(flowName);

        // flow inputs
        var renewal = component.get("v.renewal");
        var recordId = component.get("v.recordId");
        var partnerID = component.get("v.partnerID");
        console.log('PartnerSignupFlowController > init - renewal: ' + renewal + ', recordId: ' + recordId + ', partnerID: ' + partnerID);
        if (partnerID) { recordId = partnerID; }

        var inputVariables = [];
        inputVariables[0] = { name : "renewal", type : "String", value: renewal };
        if (recordId) {
            inputVariables[1] = { name : "recordId", type : "String", value: recordId };
        }
        console.log('PartnerSignupFlowController > init - inputVariables: ' + JSON.stringify(inputVariables));

        // start the flow by the flow Unique Name
        flow.startFlow(flowName, inputVariables);

    }, // end init

});