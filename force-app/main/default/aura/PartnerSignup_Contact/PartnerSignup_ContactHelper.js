/**
 * Created by ryan.cox on 2019-09-18.
 */

({
    getDeviceType: function(component) {

        var deviceType = $A.get("$Browser.formFactor");
        component.set("v.deviceType", deviceType);

    }, // end getDeviceType

   getAccount: function(component) {

        var accountID = component.get("v.accountID");
        console.log('PartnerSignup_ContactHelper > getAccount - accountID: ' + accountID);

        // Create the action
        var doAction = true;
        var action = component.get("c.getAccountContacts"); // method on the PartnerSignupController
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
                console.log('PartnerSignup_ContactHelper > getAccount - response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    var account = response.getReturnValue();
                    component.set("v.account", account);
                    console.log("PartnerSignup_ContactHelper > getAccount:" + JSON.stringify(account));

                    // executive director
                    var executiveDirector_orig = {
                        "Id" : account.Executive_Director__r.Id,
                        "FirstName" : account.Executive_Director__r.FirstName,
                        "LastName" : account.Executive_Director__r.LastName,
                        "Email" : account.Executive_Director__r.Email,
                        "MobilePhone" : account.Executive_Director__r.MobilePhone,
                        "npe01__WorkPhone__c" : account.Executive_Director__r.npe01__WorkPhone__c
                    };
                    var executiveDirector = Object.assign({}, executiveDirector_orig); // clone javascript object

                    component.set("v.executiveDirector_orig", executiveDirector_orig);
                    component.set("v.executiveDirector", executiveDirector);
                    //console.log('PartnerSignup_ContactHelper > getAccount - executiveDirector_orig: ' + JSON.stringify(component.get("v.executiveDirector_orig")));
                    //console.log('PartnerSignup_ContactHelper > getAccount - executiveDirector: ' + JSON.stringify(component.get("v.executiveDirector")))

                    // primary contact
                    var primaryContact_orig = {
                      "Id" : account.npe01__One2OneContact__r.Id,
                      "FirstName" : account.npe01__One2OneContact__r.FirstName,
                      "LastName" : account.npe01__One2OneContact__r.LastName,
                      "Email" : account.npe01__One2OneContact__r.Email,
                      "MobilePhone" : account.npe01__One2OneContact__r.MobilePhone,
                      "npe01__WorkPhone__c" : account.npe01__One2OneContact__r.npe01__WorkPhone__c
                    };
                    var primaryContact = Object.assign({}, primaryContact_orig); // clone javascript object

                    component.set("v.primaryContact_orig", primaryContact_orig);
                    component.set("v.primaryContact", primaryContact);

                    // set this component to 'isUpdate', meaning this instance is for a renewal
                    this.setAccountUpdate(component);
                }
                else {
                    console.log("PartnerSignup_ContactHelper > getAccount - failed with state: " + state);
                }
            });

            // Send action off to be executed
        	$A.enqueueAction(action);

        } // end doAction

    }, // end getAccount

   setAccountUpdate: function(component) {

        // account already exists; submit updates to the account only
        component.set("v.isUpdate", true);

        // isPrimaryContact
        var executiveDirector = component.get("v.executiveDirector");
        var primaryContact = component.get("v.primaryContact");
        if (executiveDirector.Id == primaryContact.Id) {
            component.set("v.isPrimaryContact", true);
            component.set("v.isPrimaryContactValue", 'Yes');
            component.set("v.primaryContact", {}); // clear primary contact
        } else {
            component.set("v.isPrimaryContact", false);
            component.set("v.isPrimaryContactValue", 'No');
        }

   }, // end setAccountUpdate

   getAccountExists: function(component, accountName) {

        return new Promise((resolve, reject) => {

            console.log('PartnerSignup_ContactHelper > getAccountExists - accountName: ' + accountName);

            // Create the action
            var action = component.get("c.accountExists"); // method on the PartnerSignupController
            if (accountName != '') {
                action.setParams({
                    "accountName": accountName
                });
            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_ContactHelper > getAccountExists - no input parameters");
                var error = new Error('getAccountExists - no input parameters');
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {

                console.log('PartnerSignup_ContactHelper > getAccountExists response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // accountExists
                    var accountExists = response.getReturnValue();
                    console.log("PartnerSignup_ContactHelper > accountExists:" + accountExists);

                    // set error message
                    var errorMessage = '';
                    if (accountExists) {
                        errorMessage = 'Partner account already exists with name: ' + accountName;
                    }
                    component.set("v.errorMessage", errorMessage);

                    // promise resolved
                    resolve();
                } else {
                    console.log("PartnerSignup_ContactHelper > getAccountExists - failed with state: " + state);
                    var error = new Error('getAccountExists - failed with state: ' + state);
                    reject(error);
                }

            }); // end callback

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end getAccountExists

	validateFields: function (component) {

        // check all fields
        var mostlyValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        // check radio group fields
        var validateFields = component.find('validate');
        var radioFieldsValid;
        if (validateFields) {
            radioFieldsValid = [].concat(validateFields).reduce(function (validSoFar, input) {
                input.showHelpMessageIfInvalid();
                return validSoFar && input.get('v.validity').valid;
            }, true);
        }
        console.log("PartnerSignup_ContactHelper > validateFields - radioFieldsValid: " + radioFieldsValid);

        var accountValid = true;
        var renewal = component.get("v.renewal");

        if (renewal == "NEW") {
            // check if account exists
            var accountName = component.get("v.account.Name");
            console.log('PartnerSignup_ContactHelper > validateFields - organizationName: ' + accountName);

            if (accountName == null) {
                accountValid = false;
            } else {
                // (promise)
                this.getAccountExists(component, accountName)
                    .then(() => {
                        // promise resolved
                        // if the account name exists, the "v.errorMessage" will be set
                        var errorMessage = component.get("v.errorMessage");
                        if (errorMessage && (errorMessage != '')) {
                            accountValid = false;
                        }
                    })
                    .catch(err => {
                        // promise rejected
                        console.error('PartnerSignup_ContactController > validateFields - error: ' + err.message);

                        // set error message
                        component.set("v.errorMessage", err.message);
                        accountValid = false;
                    })
            }
        } // end if NEW

        // trim field values to prevent white spaces from causing issues when looking up existing contacts

        // executiveDirector
        var firstName = component.get('v.executiveDirector.FirstName');
        if (firstName != null) {
		    firstName = firstName.trim();
		    component.set('v.executiveDirector.FirstName', firstName);
        }

        var lastName = component.get('v.executiveDirector.LastName');
        if (lastName != null) {
		    lastName = lastName.trim();
		    component.set('v.executiveDirector.LastName', lastName);
        }

        var email = component.get('v.executiveDirector.Email');
        if (email != null) {
		    email = email.trim();
		    component.set('v.executiveDirector.Email', email);
        }

        var mobilePhone = component.get('v.executiveDirector.MobilePhone');
        if (mobilePhone != null) {
            mobilePhone = mobilePhone.trim();
            if (mobilePhone.length == 10) {
                mobilePhone = mobilePhone.substring(0,3) + '-' + mobilePhone.substring(3,6) + '-' + mobilePhone.substring(6,10);
            }
            component.set('v.executiveDirector.MobilePhone', mobilePhone);
        }

        var workPhone = component.get('v.executiveDirector.npe01__WorkPhone__c');
        if (workPhone != null) {
            workPhone = workPhone.trim();
            if (workPhone.length == 10) {
                workPhone = workPhone.substring(0,3) + '-' + workPhone.substring(3,6) + '-' + workPhone.substring(6,10);
            }
            component.set('v.executiveDirector.npe01__WorkPhone__c', workPhone);
        }

        // update primary contact if not the same contact as executive director
        var isPrimaryContact = component.get("v.isPrimaryContact");
        if (!isPrimaryContact) {

            firstName = component.get('v.primaryContact.FirstName');
            if (firstName != null) {
                firstName = firstName.trim();
                component.set('v.primaryContact.FirstName', firstName);
            }

            lastName = component.get('v.primaryContact.LastName');
            if (lastName != null) {
                lastName = lastName.trim();
                component.set('v.primaryContact.LastName', lastName);
            }

            email = component.get('v.primaryContact.Email');
            if (email != null) {
                email = email.trim();
                component.set('v.primaryContact.Email', email);
            }

            mobilePhone = component.get('v.primaryContact.MobilePhone');
            if (mobilePhone != null) {
                mobilePhone = mobilePhone.trim();
                if (mobilePhone.length == 10) {
                    mobilePhone = mobilePhone.substring(0,3) + '-' + mobilePhone.substring(3,6) + '-' + mobilePhone.substring(6,10);
                }
                component.set('v.primaryContact.MobilePhone', mobilePhone);
            }

            workPhone = component.get('v.primaryContact.npe01__WorkPhone__c');
            if (workPhone != null) {
                workPhone = workPhone.trim();
                if (workPhone.length == 10) {
                    workPhone = workPhone.substring(0,3) + '-' + workPhone.substring(3,6) + '-' + workPhone.substring(6,10);
                }
                component.set('v.primaryContact.npe01__WorkPhone__c', workPhone);
            }

        } // end primary contact

        // address
        var state = component.get('v.account.BillingState');
        if (state != null) {
            state = state.toUpperCase();
            component.set('v.account.BillingState', state);
        }

        return (mostlyValid && radioFieldsValid && accountValid);

	}, // end validateFields

    navigate: function (component, buttonClicked) {

        component.set('v.navigation', buttonClicked);
        console.log('PartnerSignup_ContactHelper > navigate - buttonClicked: ' + buttonClicked);

        // set 'navigation' attribute that the flow will use to determine flow path
        // go forward in the flow; this does the same thing as the "Next" button in the standard flow footer
        var navigate = component.get("v.navigateFlow");
        if (navigate) {
            navigate("NEXT");
        }

    }, // end navigate

   createAccount: function(component) {

        return new Promise((resolve, reject) => {

            var account = component.get("v.account");
            var executiveDirector = component.get("v.executiveDirector");
            var isExecutiveDirector = component.get("v.isExecutiveDirector");
            var primaryContact = component.get("v.primaryContact");
            var isPrimaryContact = component.get("v.isPrimaryContact");

            console.log('PartnerSignup_ContactHelper > createAccount - account: ' + JSON.stringify(account)
                + ', executiveDirector: ' + JSON.stringify(executiveDirector)
                + ', primaryContact: ' + JSON.stringify(primaryContact));

            // Create the action
            var action = component.get("c.createAccount"); // method on the PartnerSignupController
            if ((account != '') && (executiveDirector != '')) {

               var partnerDetails = {
                    "partner": account,
                    "executiveDirector": executiveDirector,
                    "isExecutiveDirector": isExecutiveDirector,
                    "primaryContact": primaryContact,
                    "isPrimaryContact": isPrimaryContact
                };

                action.setParams(
                    { "partnerDetails" : partnerDetails }
                );
            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_ContactHelper > createAccount - no input parameters");
                var error = new Error('createAccount - no input parameters');
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {

                console.log('PartnerSignup_ContactHelper > createAccount response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // response
                    var partnerDetails = response.getReturnValue();
                    console.log("PartnerSignup_ContactHelper > createAccount - account created:" + JSON.stringify(partnerDetails));
                    console.log("PartnerSignup_ContactHelper > createAccount - accountID:" + partnerDetails.partner.Id);
                    component.set("v.account", partnerDetails.partner);
                    component.set("v.executiveDirector", partnerDetails.executiveDirector);
                    component.set("v.primaryContact", partnerDetails.primaryContact);

                    if (partnerDetails.errorMessage) {
                        // promise rejected - throw error
                        console.log("PartnerSignup_ContactHelper > createAccount - error: " + partnerDetails.errorMessage);
                        var error = new Error('createAccount - error: ' + partnerDetails.errorMessage);
                        reject(error);
                    } else {
                        // promise resolved
                        resolve();
                    }

                } else {
                    // promise rejected - throw error
                    console.log("PartnerSignup_ContactHelper > createAccount - failed with state: " + state);
                    var error = new Error('createAccount - failed with state: ' + state);
                    reject(error);
                }

            }); // end callback

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end createAccount

   updateAccount: function(component) {

        return new Promise((resolve, reject) => {

            var account = component.get("v.account");
            var executiveDirector_orig = component.get("v.executiveDirector_orig");
            var executiveDirector = component.get("v.executiveDirector");
            var isExecutiveDirector = component.get("v.isExecutiveDirector");
            var primaryContact_orig = component.get("v.primaryContact_orig");
            var primaryContact = component.get("v.primaryContact");
            var isPrimaryContact = component.get("v.isPrimaryContact");

            //console.log('PartnerSignup_ContactHelper > updateAccount - executiveDirector_orig: ' + JSON.stringify(executiveDirector_orig));
            //console.log('PartnerSignup_ContactHelper > updateAccount - executiveDirector: ' + JSON.stringify(executiveDirector));
            var executiveDirectorAction = this.compareContact(executiveDirector_orig, executiveDirector);
            console.log('PartnerSignup_ContactHelper > updateAccount - executiveDirectorAction: ' + executiveDirectorAction)
            var primaryContactAction = (isPrimaryContact) ? 'EXECUTIVE_DIRECTOR': this.compareContact(primaryContact_orig, primaryContact);
            console.log('PartnerSignup_ContactHelper > updateAccount - primaryContactAction: ' + primaryContactAction)

            console.log('PartnerSignup_ContactHelper > updateAccount - account: ' + JSON.stringify(account)
                + ', executiveDirector: ' + JSON.stringify(executiveDirector)
                + ', executiveDirectorAction: ' + executiveDirectorAction
                + ', primaryContact: ' + JSON.stringify(primaryContact)
                + ', primaryContactAction: ' + primaryContactAction
                );

            // Create the action
            var action = component.get("c.updateAccount"); // method on the PartnerSignupController
            if ((account != '') && (executiveDirector != '')) {

               var partnerDetails = {
                    "partner": account,
                    "executiveDirector": executiveDirector,
                    "isExecutiveDirector": isExecutiveDirector,
                    "primaryContact": primaryContact,
                    "isPrimaryContact": isPrimaryContact,
                    "executiveDirectorAction": executiveDirectorAction,
                    "primaryContactAction": primaryContactAction
                };

                action.setParams(
                    { "partnerDetails" : partnerDetails }
                );
            } else {
                // no input parameters
                // promise rejected - throw error
                console.log("PartnerSignup_ContactHelper > updateAccount - no input parameters");
                var error = new Error('createAccount - no input parameters');
                reject(error);
            }

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {

                console.log('PartnerSignup_ContactHelper > updateAccount response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // response
                    var partnerDetails = response.getReturnValue();

                    if (partnerDetails.errorMessage) {
                        console.log("PartnerSignup_ContactHelper > updateAccount - error: " + partnerDetails.errorMessage);
                        var error = new Error('updateAccount - error: ' + partnerDetails.errorMessage);
                        reject(error);
                    } else {
                        console.log("PartnerSignup_ContactHelper > updateAccount - account updated:" + JSON.stringify(partnerDetails));
                        console.log("PartnerSignup_ContactHelper > updateAccount - accountID:" + partnerDetails.partner.Id);
                        component.set("v.account", partnerDetails.partner);
                        component.set("v.executiveDirector", partnerDetails.executiveDirector);
                        component.set("v.primaryContact", partnerDetails.primaryContact);

                        // promise resolved
                        resolve();
                    }
                }
                else {
                    // promise rejected - throw error
                    console.log("PartnerSignup_ContactHelper > updateAccount - failed with state: " + state);
                    var error = new Error('updateAccount - failed with state: ' + state);
                    reject(error);
                }

            }); // end callback

            // Send action off to be executed
            $A.enqueueAction(action);

        }) // end promise

    }, // end updateAccount

    compareContact: function(contact_orig, contact) {

       var action;
       if ((contact.FirstName == contact_orig.FirstName)
            && (contact.LastName == contact_orig.LastName)
            && (contact.Email == contact_orig.Email)
            && (contact.MobilePhone == contact_orig.MobilePhone)
            && (contact.npe01__WorkPhone__c == contact_orig.npe01__WorkPhone__c)
        ) {
            action = 'NO_CHANGE';
        } else if ((contact.FirstName == contact_orig.FirstName)
            && (contact.LastName == contact_orig.LastName)
            && (contact.Email == contact_orig.Email)
        ) {
            action = 'UPDATE';
        } else {
            action = 'CREATE';
        }
        //console.log("PartnerSignup_ContactHelper > compareContact - " + action + " contact: " + JSON.stringify(contact));

        return action;

    } // end compare

});