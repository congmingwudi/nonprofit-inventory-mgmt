({

   getPartnerAgreement: function(component) {

        var partnerAgreementName = component.get("v.partnerAgreementName");
        console.log('PartnerSignup_AgreementHelper > getPartnerAgreement - partnerAgreementName: [' + partnerAgreementName + ']');

        // Create the action
        var doAction = true;
        var action = component.get("c.getPartnerAgreement"); // method on the PartnerSignupController

        if (partnerAgreementName != '') {
            action.setParams({
                "partnerAgreementName": partnerAgreementName
            });
        } else {
            // no input parameters
            doAction = false;
        }

        if (doAction) {

             // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                console.log('PartnerSignup_AgreementHelper > getPartnerAgreement response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    var partnerAgreementDetails = response.getReturnValue();
                    console.log("PartnerSignup_AgreementHelper > partnerAgreement:" + JSON.stringify(partnerAgreementDetails));
                    if (partnerAgreementDetails) {
                        component.set("v.partnerAgreement", partnerAgreementDetails.partnerAgreement);
                        component.set("v.partnerAgreementID", partnerAgreementDetails.partnerAgreement.Id);
                        component.set("v.siteName", partnerAgreementDetails.siteName);
                        component.set("v.downloadFileName", partnerAgreementDetails.downloadFileName);
                    }
                }
                else {
                    console.log("PartnerSignup_AgreementHelper > getPartnerAgreement - failed with state: " + state);
                }
            });

            // Send action off to be executed
        	$A.enqueueAction(action);

        } // end doAction

    }, // end getPartnerAgreement

   partnerAgreementSigned: function(component) {

        return new Promise((resolve, reject) => {

            var partnerAgreementID = component.get("v.partnerAgreementID");
            var renewal = component.get("v.renewal");
            console.log('PartnerSignup_AgreementHelper > partnerAgreementSigned - partnerAgreementID: ' + partnerAgreementID + ', renewal: ' + renewal);

            // Create the action
            var action = component.get("c.updatePartnerAgreementSigned"); // method on the PartnerSignupController
            if ((partnerAgreementID != '') && (renewal != '')) {

                var partnerAgreementDetails = {
                    "partnerAgreementID": partnerAgreementID,
                    "renewal": renewal
                };
                console.log('PartnerSignup_AgreementHelper > partnerAgreementSigned - inpput partnerAgreementDetails: ' + JSON.stringify(partnerAgreementDetails));

                action.setParams(
                    { "partnerAgreementDetails" : partnerAgreementDetails }
                );

            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_AgreementHelper > partnerAgreementSigned - no input parameters");
                var error = new Error('partnerAgreementSigned - no input parameters');

                // promise rejected
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                console.log('PartnerSignup_AgreementHelper > partnerAgreementSigned - response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // response
                    var partnerAgreementDetails = response.getReturnValue();
                    console.log('PartnerSignup_AgreementHelper > partnerAgreementSigned - response partnerAgreementDetails: ' + JSON.stringify(partnerAgreementDetails));

                    var errorMessage = partnerAgreementDetails.errorMessage;
                    if (errorMessage) {
                        console.log("PartnerSignup_AgreementHelper > partnerAgreementSigned - error: " + errorMessage);
                        var error = new Error('partnerAgreementSigned - error: ' + errorMessage);

                        // promise rejected
                        reject(error);
                    } else {
                        var signedDate = partnerAgreementDetails.signedByPartnerDate;
                        console.log("PartnerSignup_AgreementHelper > partnerAgreementSigned - signedDate:" + JSON.stringify(signedDate));
                        component.set("v.partnerAgreement.Date_Signed_By_Partner__c", signedDate);

                        // promise resolved
                        resolve();
                    }

                } else {
                    console.log("PartnerSignup_AgreementHelper > partnerAgreementSigned - failed with state: " + state);
                    var error = new Error('partnerAgreementSigned - failed with state: ' + state);

                    // promise rejected
                    reject(error);
                }

            }); // end callback

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end partnerAgreementSigned

	validateFields: function (component) {

        var signatureSaved = component.get("v.signatureSaved");
        console.log('PartnerSignup_AgreementHelper > validate - signatureSaved: ' + signatureSaved);

        if (!signatureSaved) {
            component.set("v.errorMessage", 'Signature is required');
        } else {
            component.set("v.errorMessage", '');
        }

        return signatureSaved;

	}, // end validateFields

    navigate: function (component, buttonClicked) {

        component.set('v.navigation', buttonClicked);
        console.log('PartnerSignup_AgreementHelper > navigate - buttonClicked: ' + buttonClicked);

        // set 'navigation' attribute that the flow will use to determine flow path
        // go forward in the flow; this does the same thing as the "Next" button in the standard flow footer
        var navigate = component.get("v.navigateFlow");
        if (navigate) {
            navigate("NEXT");
        }

    }, // end navigate

});