/**
 * Created by ryan.cox on 1/27/20.
 */

/*
custom type for passing details to the PartnerAgreements_Create invocable method
to create current partner agreements for a partner account
*/
public without sharing class PartnerAgreements {

    @InvocableVariable(label='Renewal' description='NEW or RENEW' required=true)
    public String renewal;

    @InvocableVariable(label='Partner Account ID' required=true)
    public String partnerAccountID;

    @InvocableVariable(label='Executive Director ID' required=true)
    public String executiveDirectorID;

    @InvocableVariable(label='Partner Agreement ID')
    public String partnerAgreementID;

    @InvocableVariable(label='Partner Agreement Name')
    public String partnerAgreementName;

    @InvocableVariable(label='Liability Waiver ID')
    public String liabilityWaiverID;

    @InvocableVariable(label='Liability Waiver Name')
    public String liabilityWaiverName;

    @InvocableVariable(label='Error Message')
    public String errorMessage;

} // end PartnerAgreements