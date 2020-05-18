({

    init: function(component, event, helper) {
        
        console.log('DonationLocationListController > init')

        helper.getDonationLocations(component);
        
    } // end init    
    
})