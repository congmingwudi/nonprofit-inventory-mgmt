/**
 * Created by ryan.cox on 1/31/20.
 */

({
    createDemographicsServed: function(component) {

        return new Promise((resolve, reject) => {

            var accountID = component.get("v.accountID");
            var numFamiliesServed = component.get("v.numFamiliesServed");
            var demographicsTableData = component.get("v.demographicsTableData");

            // demographicsTableData here is formatted as a List of objects that match the table data structure
            // so each entry in the list will look like {"RaceEthnicity":"African","PercentFamiliesServed":"100","NumFamiliesServed":10}
            // the demographicTableData is passed to the apex controller as a json string, where it is deserialized into a list of objects

            console.log('PartnerSignup_DemographicsHelper > createDemographicsServed - for accountID: ' + accountID
                + ', numFamiliesServed: ' + numFamiliesServed + ', demographicsTableData: ' + JSON.stringify(demographicsTableData));

            // Create the action
            var action = component.get("c.createDemographicsServed"); // method on the PartnerSignupController
            if (accountID) {
                action.setParams({
                    "accountID": accountID,
                    "numFamiliesServed": numFamiliesServed,
                    "demographicList": JSON.stringify(demographicsTableData)
                });
            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_DemographicsHelper > createDemographicsServed - no input parameters");
                var error = new Error('createAccount - no input parameters');
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('PartnerSignup_DemographicsHelper > createDemographicsServed - response: ' + response.getState())

                if (state === "SUCCESS") {

                    // response
                    var responseList = response.getReturnValue();
                    console.log('PartnerSignup_DemographicsHelper > createDemographicsServed -responseList: ' + JSON.stringify(responseList));

                    // promise resolved
                    resolve();

                }  else {
                    console.log("PartnerSignup_DemographicsHelper > createDemographicsServed - failed with state: " + state);
                    var error = new Error('createDemographicsServed - failed with state: ' + state);
                    reject(error);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end createDemographics

   updateDemographicsServed: function(component) {

        return new Promise((resolve, reject) => {

            var accountID = component.get("v.accountID");
            var numFamiliesServed = component.get("v.numFamiliesServed");
            var demographicsTableData = component.get("v.demographicsTableData");

            // demographicsTableData here is formatted as a List of objects that match the table data structure
            // so each entry in the list will look like {"RaceEthnicity":"African","PercentFamiliesServed":"100","NumFamiliesServed":10}
            // the demographicTableData is passed to the apex controller as a json string, where it is deserialized into a list of objects

            console.log('PartnerSignup_DemographicsHelper > updateDemographicsServed - for accountID: ' + accountID
                + ', numFamiliesServed: ' + numFamiliesServed + ', demographicsTableData: ' + JSON.stringify(demographicsTableData));

            // Create the action
            var action = component.get("c.updateDemographicsServed"); // method on the PartnerSignupController
            if (accountID) {
                action.setParams({
                    "accountID": accountID,
                    "numFamiliesServed": numFamiliesServed,
                    "demographicList": JSON.stringify(demographicsTableData)
                });
            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_DemographicsHelper > updateDemographicsServed - no input parameters");
                var error = new Error('createAccount - no input parameters');
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('PartnerSignup_DemographicsHelper > updateDemographicsServed - response: ' + response.getState())

                if (state === "SUCCESS") {

                    // response
                    var responseList = response.getReturnValue();
                    console.log('PartnerSignup_DemographicsHelper > updateDemographicsServed -responseList: ' + JSON.stringify(responseList));

                    // promise resolved
                    resolve();

                }  else {
                    console.log("PartnerSignup_DemographicsHelper > updateDemographicsServed - failed with state: " + state);
                    var error = new Error('updateDemographicsServed - failed with state: ' + state);
                    reject(error);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end updateDemographicsServed

	validateFields: function (component) {

        console.log("PartnerSignup_DemographicsHelper > validateFields");

        var errorMessage = "";
        var numFamilies_ok = false;
        var percentage_ok = false;

        var numFamiliesServed = component.get('v.numFamiliesServed');
        var total_PercentFamiliesServed = component.get('v.total_PercentFamiliesServed');

        // check num families > 0
        if (numFamiliesServed > 0) {
            numFamilies_ok = true;
        } else {
            errorMessage += '# Children Served must be greater than 0 ';
        }

        // check if total percentage is 100%
        if (total_PercentFamiliesServed == 100) {
            percentage_ok = true;
        } else {
            if (errorMessage != "") { errorMessage += ", and "; }
            errorMessage += 'Total % Children Served must equal 100';
        }

        if (numFamilies_ok && percentage_ok) {
            return true;
        } else {
            component.set('v.errorMessage', errorMessage);
            console.log("PartnerSignup_DemographicsHelper > validateFields - errorMessage: " + errorMessage);
            return false;
        }

	}, // end validateFields

    navigate: function (component, buttonClicked) {

        component.set('v.navigation', buttonClicked);
        console.log('PartnerSignup_DemographicsHelper > navigate - buttonClicked: ' + buttonClicked);

        // set 'navigation' attribute that the flow will use to determine flow path
        // go forward in the flow; this does the same thing as the "Next" button in the standard flow footer
        var navigate = component.get("v.navigateFlow");
        if (navigate) {
            navigate("NEXT");
        }

    }, // end navigate

});