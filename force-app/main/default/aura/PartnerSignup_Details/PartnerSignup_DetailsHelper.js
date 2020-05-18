/**
 * Created by ryan.cox on 2019-09-18.
 */

({

   getAccount: function(component) {

        var accountID = component.get("v.accountID");
        console.log('PartnerSignup_DetailsHelper > getAccount - accountID: ' + accountID);

        // Create the action
        var doAction = true;
        var action = component.get("c.getAccountDetails"); // method on the PartnerSignupController
        if (accountID != '') {
            action.setParams({
                "accountID": accountID
            });
        } else {
            // no input parameters
            doAction = false;
        }

        if (doAction) {

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                console.log('PartnerSignup_DetailsHelper > getAccount response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    var renewal = component.get("v.renewal");
                    console.log("PartnerSignup_DetailsHelper > getAccount - renewal: " + renewal);

                    var formFirstTime = component.get("v.formFirstTime");
                    console.log("PartnerSignup_DetailsHelper > getAccount - formFirstTime: " + formFirstTime);

                    var account = response.getReturnValue();

                    if ((renewal == 'RENEW') || !formFirstTime) {
                        var is501c3 = "No";
                        if (account.is501c3__c) { is501c3 = "Yes" }
                        component.set("v.is501c3", is501c3);
                        console.log("PartnerSignup_DetailsHelper > is501c3: " + is501c3);

                        var acceptDonations = "No";
                        if (account.Accept_Donations__c) { acceptDonations = "Yes" }
                        component.set("v.acceptDonations", acceptDonations);
                        console.log("PartnerSignup_DetailsHelper > acceptDonations: " + acceptDonations);

                        var canPickupItems = "No";
                        if (account.Pick_Up_Items__c) { canPickupItems = "Yes" }
                        component.set("v.canPickupItems", canPickupItems);
                        console.log("PartnerSignup_DetailsHelper > canPickupItems: " + canPickupItems);
                    }

                    if (account.Counties_Served__c) {
                        var countyValues = account.Counties_Served__c.split(";");
                        console.log("PartnerSignup_DetailsHelper > countyValues: " + countyValues);
                        component.set("v.countyValues", countyValues);
                    }

                    console.log("PartnerSignup_DetailsHelper > getAccount:" + JSON.stringify(account));
                    component.set("v.account", account);

                }
                else {
                    console.log("PartnerSignup_DetailsHelper > getAccount - failed with state: " + state);
                }
            });

            // Send action off to be executed
        	$A.enqueueAction(action);

        } // end doAction

    }, // end getAccount

   getCountyOptions: function(component) {

        console.log('PartnerSignup_DetailsHelper > getCountyOptions');

        // Create the action
        var doAction = true;
        var action = component.get("c.getCountyOptions"); // method on the PartnerSignupController

        if (doAction) {

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                //console.log('PartnerSignup_DetailsHelper > getCountyOptions response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    var countyOptions = response.getReturnValue();
                    //console.log("PartnerSignup_DetailsHelper > getCountyOptions - countyOptions:" + JSON.stringify(countyOptions));
                    component.set("v.countyOptions", countyOptions);

                }
                else {
                    console.log("PartnerSignup_DetailsHelper > getCountyOptions - failed with state: " + state);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        } // end doAction

    }, // end getCountyOptions

   getLocationInfo: function(component) {

        console.log('PartnerSignup_DetailsHelper > getLocationInfo');

        // Create the action
        var doAction = true;
        var action = component.get("c.getLocationInfo"); // method on the PartnerSignupController

        if (doAction) {

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('PartnerSignup_DetailsHelper > getLocationInfo - response state: ' + response.getState())
                if (state === "SUCCESS") {

                    var locationInfo = response.getReturnValue();
                    console.log("PartnerSignup_DetailsHelper > getLocationInfo - locationInfo:" + JSON.stringify(locationInfo));
                    component.set("v.fullAddress", locationInfo.fullAddress);
                    component.set("v.mapURL", locationInfo.mapURL);
                }
                else {
                    console.log("PartnerSignup_DetailsHelper > getLocationInfo - failed with state: " + state);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        } // end doAction

    }, // end getLocationInfo

	validateFields: function (component) {

        console.log("PartnerSignup_DetailsHelper > validateFields");

        // checks all fields
        var mostlyValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log("PartnerSignup_DetailsHelper > validateFields - mostlyValid: " + mostlyValid);

        // check radio group fields
        var validateFields = component.find('validate');
        var radioFieldsValid;
        if (validateFields) {
            radioFieldsValid = [].concat(validateFields).reduce(function (validSoFar, input) {
                input.showHelpMessageIfInvalid();
                return validSoFar && input.get('v.validity').valid;
            }, true);
        }
        console.log("PartnerSignup_DetailsHelper > validateFields - radioFieldsValid: " + radioFieldsValid);

        return (mostlyValid && radioFieldsValid);

	}, // end validateFields

    navigate: function (component, buttonClicked) {

        component.set('v.navigation', buttonClicked);
        console.log('PartnerSignup_DetailsHelper > navigate - buttonClicked: ' + buttonClicked);

        // set 'navigation' attribute that the flow will use to determine flow path
        // go forward in the flow; this does the same thing as the "Next" button in the standard flow footer
        var navigate = component.get("v.navigateFlow");
        if (navigate) {
            navigate("NEXT");
        }

    }, // end navigate

   updateAccount: function(component) {

        return new Promise((resolve, reject) => {

            var account = component.get("v.account");

            console.log('PartnerSignup_DetailsHelper > updateAccount - account: ' + JSON.stringify(account));

            // get selected counties served
            account.Counties_Served__c = this.getCountiesSelected(component);

            // Create the action
            var action = component.get("c.updateAccount"); // method on the PartnerSignupController
            if (account != '') {

               var partnerDetails = {
                    "partner": account
                };

                action.setParams(
                    { "partnerDetails" : partnerDetails }
                );
            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_DetailsHelper > createAccount - no input parameters");
                var error = new Error('createAccount - no input parameters');
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                console.log('PartnerSignup_DetailsHelper > updateAccount response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // response
                    var partnerDetails = response.getReturnValue();
                    console.log("PartnerSignup_DetailsHelper > updateAccount - partnerDetails:" + JSON.stringify(partnerDetails));
                    component.set("v.account", partnerDetails.partner);

                    if (partnerDetails.errorMessage) {
                        // promise rejected - throw error
                        console.log("PartnerSignup_DetailsHelper > updateAccount - error: " + partnerDetails.errorMessage);
                        var error = new Error('updateAccount - error: ' + partnerDetails.errorMessage);
                        reject(error);
                    } else {
                        // promise resolved
                        resolve();
                    }

                } else {
                    console.log("PartnerSignup_DetailsHelper > updateAccount - failed with state: " + state);
                    var error = new Error('updateAccount - failed with state: ' + state);
                    reject(error);
                }

            }); // end callback

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end updateAccount

    getCountiesSelected: function(component) {

        console.log('PartnerSignup_DetailsHelper > getCountiesSelected');

        var countyValues = component.get('v.countyValues');
        console.log('PartnerSignup_DetailsHelper > getCountiesSelected - countyValues: ' + countyValues);

        var countiesSelected = '';
        for (var i = 0; i < countyValues.length; ++i) {
            console.log('county value: ' + countyValues[i]);
            countiesSelected += countyValues[i] + ';'
        }

        console.log('PartnerSignup_DetailsHelper > getCountiesSelected - countiesSelected: ' + countiesSelected);
        return countiesSelected;

    } // getCountiesSelected

});