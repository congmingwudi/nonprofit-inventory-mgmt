/**
 * Created by ryan.cox on 1/27/20.
 */

/*
custom type for passing details from lightning component to invocable methods in the PartnerSignupController
also can be used an Apex-defined type in flows, if needed.
*/
public without sharing class PartnerDetails {

    @AuraEnabled
    public Account partner {get; set;}

    @AuraEnabled
    public Contact executiveDirector {get; set;}

    @AuraEnabled
    public Boolean isExecutiveDirector {get; set;}

    @AuraEnabled
    public Contact primaryContact {get; set;}

    @AuraEnabled
    public Boolean isPrimaryContact {get; set;}

    @AuraEnabled
    public String executiveDirectorAction {get; set;}

    @AuraEnabled
    public String primaryContactAction {get; set;}

    @AuraEnabled
    public String errorMessage {get; set;}

}