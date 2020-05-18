@isTest
private class DonationLocationController_Test {

    @isTest static void test_getDonationLocations() {
        
        System.debug('DonationLocationController_Test >> test_getDonationLocations > start');
    	List<Donation_Location__c> locationList = DonationLocationController.getDonationLocations();
        System.debug('DonationLocationController_Test >> test_getDonationLocations > locationList: ' + locationList);
    }
    
} // end DonationLocationController_Test