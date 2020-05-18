/**
 * Created by ryan.cox on 2/9/20.
 */

global with sharing class PartnerDetailsInvocable {

    @InvocableVariable
    global String renewal; // NEW or RENEW, indicates form submitted for partner waitlist signup or renewing partner agreements

    @InvocableVariable
    global String partnerID;

    @InvocableVariable
    global Boolean isExecutiveDirector;

    @InvocableVariable
    global String flowStep;

}