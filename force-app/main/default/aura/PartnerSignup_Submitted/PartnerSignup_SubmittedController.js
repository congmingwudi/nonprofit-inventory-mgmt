/**
 * Created by ryan.cox on 2/6/20.
 */

({
    init: function(component, event, helper) {

        console.log('PartnerSignup_SubmittedController > init');

        //helper.getAccount(component);

    }, // end init

    handleNavigation : function(component, event, helper) {

        console.log('PartnerSignup_SubmittedController > handleNavigation');

        // navigate flow
        var buttonClicked = event.getSource().getLocalId();
        helper.navigate(component, buttonClicked)

    }, // end handleNavigation

});