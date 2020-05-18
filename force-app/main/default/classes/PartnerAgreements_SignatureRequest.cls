/**
 * Created by ryan.cox on 2/16/20.
 */

global without sharing class PartnerAgreements_SignatureRequest {

    static String bccEmail = 'ryan.cox@salesforce.com';
    static String emailTemplate = 'Partner_Signup_Signatures';

    @InvocableMethod(label='Partner Agreements Signature Request')
    global static void signatureRequest(List<PartnerDetailsInvocable> partnerDetailsList) {

        for (PartnerDetailsInvocable partnerDetails : partnerDetailsList) {

            System.debug('PartnerAgreements_SignatureRequest > partnerDetails: ' + partnerDetails);
            String partnerID = partnerDetails.partnerID;

            // get partner account
            Account partner = [SELECT Id, Name,
                    Executive_Director__c, Executive_Director__r.Email,
                    npe01__One2OneContact__r.Email
            FROM Account WHERE Id = :partnerID LIMIT 1];
            System.debug('PartnerAgreements_SignatureRequest > account: ' + partner);

            // send email to partner
            sendEmail(partner);

        } // end for

    } // end submitted

    static void sendEmail(Account partner) {

        System.debug('PartnerAgreements_SignatureRequest > sendEmail - partner: ' + partner);

        // email
        Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        // to email address
        String execEmail = partner.Executive_Director__r.Email;
        String primaryEmail = partner.npe01__One2OneContact__r.Email;
        message.setToAddresses(new String[]{ execEmail });
        message.setCcAddresses(new String[]{ primaryEmail });
        message.setBccAddresses(new String[]{ bccEmail });

        // activity
        message.setTargetObjectId(partner.Executive_Director__c);
        message.setSaveAsActivity(true);

        // from email address from Org Wide Email
        ID fromEmailID = PartnerSignupController.getOrgWideEmailID();
        if (fromEmailID != null) {
            message.setOrgWideEmailAddressId(fromEmailID);
            message.setUseSignature(false); // removes org-wide user's email signature
        } // otherwise email will be sent from current user

        // email template
        ID emailTemplateID = PartnerSignupController.getEmailTemplateID(emailTemplate);
        if (emailTemplateID != null) {
            message.setWhatId(partner.Id);
            message.setTemplateID(emailTemplateID);
            emails.add(message);
        }

        // send email
        System.debug('PartnerAgreements_SignatureRequest > sendEmail - email messages: ' + emails);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        System.debug('PartnerAgreements_SignatureRequest > sendEmail - results: ' + results);

    } // end sendEmail

} // end PartnerAgreements_SignatureRequest