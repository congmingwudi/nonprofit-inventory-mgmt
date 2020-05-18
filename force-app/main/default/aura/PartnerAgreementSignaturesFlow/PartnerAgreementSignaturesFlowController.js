/**
 * Created by ryan.cox on 2/10/20.
 */

({

   init: function(component, event, helper) {

        var flowName = "Partner_Agreement_Signatures";
        console.log('PartnerAgreementSignaturesFlowController > init - flowName: ' + flowName);

        // find the view component (by aura:id) where the flow will be displayed
        var flow = component.find(flowName);

        // flow inputs
        var recordId = component.get("v.recordId");
        var partnerID = component.get("v.partnerID");
        console.log('PartnerAgreementSignaturesFlowController > init - recordId: ' + recordId + ', partnerID: ' + partnerID);
        if (partnerID) { recordId = partnerID; }

        var inputVariables = [];
        inputVariables[0] = { name : "recordId", type : "String", value: recordId };
        console.log('PartnerAgreementSignaturesFlowController > init - inputVariables: ' + JSON.stringify(inputVariables));

        // start the flow by the flow Unique Name
        flow.startFlow(flowName, inputVariables);

    }, // end init

});