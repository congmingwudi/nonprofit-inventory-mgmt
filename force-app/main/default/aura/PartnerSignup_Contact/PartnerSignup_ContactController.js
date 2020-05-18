/**
 * Created by ryan.cox on 2019-09-18.
 */

({

    init: function(component, event, helper) {

        // check if partner signup or renewal
        var renewal = component.get("v.renewal");
        var accountID = component.get("v.accountID");
        console.log('PartnerSignup_ContactController > init - renewal: ' + renewal + ', accountID: ' + accountID);

        if (accountID && (accountID != '') && (renewal == 'RENEW')) {
            console.log('PartnerSignup_ContactController > init - partner renewal');

            // assume user is the executive director initially because they are the ones receiving the renewal email
            component.set("v.isExecutiveDirector", true);
            component.set("v.isExecutiveDirectorValue", 'Yes');

            // load existing account contacts
            helper.getAccount(component);
        } else {
            console.log('PartnerSignup_ContactController > init - partner signup');
        }

        // check account exists
        var account = component.get("v.account"); // works for renewals and if flow directs back to this page for updating
        if (account.Id) {
            console.log('PartnerSignup_ContactController > init - account.Id: ' + account.Id);
            helper.setAccountUpdate(component);
        }

        // device form factor
        var deviceType = component.get("v.deviceType");
        if (deviceType == "") {
            helper.getDeviceType(component);
        }

    }, // end init

    isExecutiveDirectorChanged: function(component, event, helper) {

        var isExecutiveDirectorValue = component.get("v.isExecutiveDirectorValue");
        console.log('PartnerSignup_ContactController > isExecutiveDirectorChanged: ' + isExecutiveDirectorValue);

        var isExecutiveDirector = false;
        if (isExecutiveDirectorValue == 'Yes') {
            isExecutiveDirector = true;
        }
        component.set("v.isExecutiveDirector", isExecutiveDirector);
        console.log('PartnerSignup_ContactController > isExecutiveDirector ' + component.get("v.isExecutiveDirector"));

    }, // end isExecutiveDirectorChanged

    isPrimaryContactChanged: function(component, event, helper) {

        var isPrimaryContactValue = component.get("v.isPrimaryContactValue");
        console.log('PartnerSignup_ContactController > isPrimaryContactChanged: ' + isPrimaryContactValue);

        if (isPrimaryContactValue == 'Yes') {
            component.set("v.isPrimaryContact", true); // hide primary contact section
        } else {
            component.set("v.isPrimaryContact", false); // show primary contact section

        }
        console.log('PartnerSignup_ContactController > isPrimaryContact ' + component.get("v.isPrimaryContact"));

    }, // end isPrimaryContactChanged

    organizationNameChanged: function(component, event, helper) {

        var renewal = component.get("v.renewal");

        if (renewal == "NEW") {
            // check if account exists
            var accountName = component.get("v.account.Name");
            console.log('PartnerSignup_ContactController > organizationNameChanged: ' + accountName);

            helper.getAccountExists(component, accountName)
                .then(() => {
                    // promise resolved
                    // if the account name exists, the "v.errorMessage" will be set
                })
                .catch(err => {
                    // promise rejected
                    console.error('PartnerSignup_ContactController > organizationNameChanged - error: ' + err.message);

                    // set error message
                    component.set("v.errorMessage", err.message);
                })
        } // end if NEW

    }, // end organizationNameChanged

    handleNavigation : function(component, event, helper) {

        var buttonClicked = event.getSource().getLocalId();
        if (buttonClicked == 'nav_cancel') {
            helper.navigate(component, buttonClicked)
        } else {

            var allGood = helper.validateFields(component);
            console.log('PartnerSignup_ContactController > handleNavigation - allGood: ' + allGood);

            if (allGood) {

                // show spinner
                component.set("v.isLoading", true);

                var isUpdate = component.get("v.isUpdate");
                console.log('PartnerSignup_ContactController > handleNavigation - isUpdate: ' + isUpdate);

                if (isUpdate) {

                    // update account (promise)
                    helper.updateAccount(component)
                        .then(() => {
                            // promise resolved

                            // navigate flow
                            var buttonClicked = event.getSource().getLocalId();
                            helper.navigate(component, buttonClicked)

                            // hide spinner
                            component.set("v.isLoading", false);
                        })
                        .catch(err => {
                            // promise rejected
                            console.error('PartnerSignup_ContactController > updateAccount - error: ' + err.message);

                            // show error message
                            component.set("v.errorMessage", err.message);

                            // hide spinner
                            component.set("v.isLoading", false);
                        })

                } else {

                    // create account (promise)
                    helper.createAccount(component)
                        .then(() => {
                            // promise resolved

                            // navigate flow
                            var buttonClicked = event.getSource().getLocalId();
                            helper.navigate(component, buttonClicked)

                            // hide spinner
                            component.set("v.isLoading", false);
                        })
                        .catch(err => {
                            // promise rejected
                            console.error('PartnerSignup_ContactController > createAccount - error: ' + err.message);

                            // show error message
                            component.set("v.errorMessage", err.message);

                            // hide spinner
                            component.set("v.isLoading", false);
                        })

                } // end create account

            } // end allGood

        }  // end not canceled

    }, // end handleNavigation

});