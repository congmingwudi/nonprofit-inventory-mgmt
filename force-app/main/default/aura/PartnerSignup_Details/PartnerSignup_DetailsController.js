/**
 * Created by ryan.cox on 2019-09-18.
 */

({

   init: function(component, event, helper) {

        console.log('PartnerSignup_DetailsController > init');

        helper.getAccount(component);
        helper.getCountyOptions(component);
        helper.getLocationInfo(component);

    }, // end init

    is501c3Changed: function(component, event, helper) {

        var is501c3 = component.get("v.is501c3");
        console.log('PartnerSignup_DetailsController > is501c3Changed: ' + is501c3);

        var organizationType = '';
        if (is501c3 == 'Yes') {
            organizationType = '501(c)3';
        }
        component.set("v.account.Organization_Type__c", organizationType);

    }, // end is501c3Changed

    acceptDonationsChanged: function(component, event, helper) {

        var acceptDonations = component.get("v.acceptDonations");
        console.log('PartnerSignup_DetailsController > acceptDonations: ' + acceptDonations);

        var acceptDonations_boolean = false;
        if (acceptDonations == 'Yes') {
            acceptDonations_boolean = true;
        }
        component.set("v.account.Accept_Donations__c", acceptDonations_boolean);

    }, // end acceptDonationsChanged

    canPickupItemsChanged: function(component, event, helper) {

        var canPickupItems = component.get("v.canPickupItems");
        console.log('PartnerSignup_DetailsController > canPickupItemsChanged: ' + canPickupItems);

        var canPickupItems_boolean = false;
        if (canPickupItems == 'Yes') {
            canPickupItems_boolean = true;
        }
        component.set("v.account.Pick_Up_Items__c", canPickupItems_boolean);

    }, // end canPickupItemsChanged

    handleNavigation : function(component, event, helper) {

        var buttonClicked = event.getSource().getLocalId();
        if (buttonClicked == 'nav_cancel') {
            helper.navigate(component, buttonClicked)
        } else {

            var allGood = helper.validateFields(component);
            console.log('PartnerSignup_DetailsController > handleNavigation - allGood: ' + allGood);

            if (allGood) {

                var processInComponent = component.get("v.processInComponent");

                // show spinner
                component.set("v.isLoading", true);

                // update account (promise)
                helper.updateAccount(component)
                    .then(() => {
                        // promise resolved

                        // next time this form is entered, existing fields from the account will be displayed
                        component.set("v.formFirstTime", false);

                        // navigate flow
                        var buttonClicked = event.getSource().getLocalId();
                        helper.navigate(component, buttonClicked)

                        // hide spinner
                        component.set("v.isLoading", false);
                    })
                    .catch(err => {
                        // promise rejected
                        console.error('PartnerSignup_DetailsController > updateAccount - error: ' + err.message);

                        // show error message
                        component.set("v.errorMessage", err.message);

                        // hide spinner
                        component.set("v.isLoading", false);
                    })

            } // end allGood

        }  // end not canceled

    }, // end handleNavigation

});