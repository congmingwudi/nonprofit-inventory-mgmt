/**
 * Created by ryan.cox on 1/31/20.
 */

({
    init: function(component, event, helper) {

        console.log('PartnerSignup_DemographicsController > init');

        var isExecutiveDirector = component.get("v.isExecutiveDirector");
        console.log('PartnerSignup_DemographicsController > init - isExecutiveDirector: ' + isExecutiveDirector);

    }, // end init

    handleNavigation : function(component, event, helper) {

        var buttonClicked = event.getSource().getLocalId();
        if (buttonClicked == 'nav_cancel') {
            helper.navigate(component, buttonClicked)
        } else {

            var allGood = helper.validateFields(component);
            console.log('PartnerSignup_DemographicsController > handleNavigation - allGood: ' + allGood);

            if (allGood) {

                // show spinner
                component.set("v.isLoading", true);

                var isUpdate = component.get("v.isUpdate");
                console.log('PartnerSignup_DemographicsController > handleNavigation - isUpdate: ' + isUpdate);

                if (isUpdate) {

                    // update account demographics served (promise)
                    helper.updateDemographicsServed(component)
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
                            console.error('PartnerSignup_DemographicsController > handleNavigation - error: ' + err.message);

                            // show error message
                            component.set("v.errorMessage", err.message);

                            // hide spinner
                            component.set("v.isLoading", false);
                        })

                } else {

                    // create account demographics served (promise)
                    helper.createDemographicsServed(component)
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
                            console.error('PartnerSignup_DemographicsController > handleNavigation - error: ' + err.message);

                            // show error message
                            component.set("v.errorMessage", err.message);

                            // hide spinner
                            component.set("v.isLoading", false);
                        })

                } // end create account

            } // end allGood

        }

    }, // end handleNavigation
});