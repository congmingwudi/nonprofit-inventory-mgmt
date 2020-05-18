/**
 * Created by ryan.cox on 2/6/20.
 */

({
    getAccount: function(component) {

        var accountID = component.get("v.accountID");
        console.log('PartnerSignup_SubmittedHelper > getAccount - accountID: ' + accountID);

        // Create the action
        var doAction = true;
        var action = component.get("c.getAccountAfterSubmission"); // method on the PartnerSignupController
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
                console.log('PartnerSignup_SubmittedHelper > getAccount response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    var account = response.getReturnValue();
                    console.log("PartnerSignup_SubmittedHelper > getAccount:" + JSON.stringify(account));
                    component.set("v.account", account);

                }
                else {
                    console.log("PartnerSignup_SubmittedHelper > getAccount - failed with state: " + state);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        } // end doAction

    }, // end getAccount

   navigate: function (component, buttonClicked) {

        component.set('v.navigation', buttonClicked);
        console.log('PartnerSignup_SubmittedHelper > navigate - buttonClicked: ' + buttonClicked);

        // set 'navigation' attribute that the flow will use to determine flow path
        // go forward in the flow; this does the same thing as the "Finish" button in the standard flow footer
        var navigate = component.get("v.navigateFlow");
        if (navigate) {
            navigate("FINISH");
        }

    }, // end navigate

});