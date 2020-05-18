/**
 * Created by ryan.cox on 2/12/20.
 */

/*
custom type for passing details to the PartnerAgreements_StorePDFs invocable method
*/
global without sharing class PartnerEventData {

    @InvocableVariable(label='Partner Account ID' required=true)
    global String partnerAccountID;

    @InvocableVariable(label='Event Type' required=true)
    global String eventType;

}