({
    init: function(component, event, helper) {

        var renewal = component.get("v.renewal");
        console.log('PartnerSignup_Agreement > init - renewal: ' + renewal);

        if (renewal == 'RENEW') {
            component.set("v.submitButtonLabel", "Submit Renewal");
            console.log('PartnerSignup_Agreement > init - submitButtonLabel: ' + component.get("v.submitButtonLabel"));
        }

        helper.getPartnerAgreement(component);

    }, // end init

    signatureSavedChanged: function(component, event, helper) {

        var signatureSaved = event.getParam('value');
        console.log('PartnerSignup_AgreementController > signatureSavedChanged: ' + signatureSaved);
        component.set("v.signatureSaved", signatureSaved);

        // show spinner
        component.set("v.isLoading", true);

        // partnerAgreementSigned
        helper.partnerAgreementSigned(component)
            .then(() => {
                // promise resolved
                component.set("v.errorMessage", '');

                // hide spinner
                component.set("v.isLoading", false);
            })
            .catch(err => {
                // promise rejected
                console.error('PartnerSignup_AgreementController > partnerAgreementSigned - error: ' + err.message);

                // show error message
                component.set("v.errorMessage", err.message);

                // hide spinner
                component.set("v.isLoading", false);
            })

    }, // end signatureSavedChanged

    handleNavigation : function(component, event, helper) {

        var allGood = helper.validateFields(component);
        console.log('PartnerSignup_AgreementController > handleNavigation - allGood: ' + allGood);

        if (allGood) {

            // navigate flow
            var buttonClicked = event.getSource().getLocalId();
            helper.navigate(component, buttonClicked)

        } // end all good

    }, // end handleNavigation

});