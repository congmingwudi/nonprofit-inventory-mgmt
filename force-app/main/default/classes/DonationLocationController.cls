public with sharing class DonationLocationController {

    @AuraEnabled
    public static List<Donation_Location__c> getDonationLocations() {
       //System.debug('DonationLocationController - getDonationLocations');
       return [SELECT Id, Name, Map_URL__c, Street_Address__c, City__c, State__c, Zip_Code__c, Donation_Location_Details__c, Website__c FROM Donation_Location__c WHERE Active__c = true];
    }  
    
} // end DonationLocationController