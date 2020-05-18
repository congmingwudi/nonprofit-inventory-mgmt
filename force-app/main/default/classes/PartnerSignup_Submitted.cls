/**
 * Created by ryan.cox on 2/7/20.
 */

global without sharing class PartnerSignup_Submitted {

    static String bccEmail = 'ryan.cox@salesforce.com';
    static String emailTemplate_SUBMITTED = 'Partner_Signup_Submitted';
    static String emailTemplate_SIGNATURES = 'Partner_Signup_Signatures';

    @InvocableMethod(label='Partner Signup Submitted')
    global static void submitted(List<PartnerDetailsInvocable> partnerDetailsList) {

        for (PartnerDetailsInvocable partnerDetails : partnerDetailsList) {

            System.debug('PartnerSignup_Submitted > partnerDetails: ' + partnerDetails);
            String partnerID = partnerDetails.partnerID;
            String renewal = partnerDetails.renewal;
            Boolean isExecutiveDirector = partnerDetails.isExecutiveDirector;

            // get partner account
            Account partner = [SELECT Id, Name,
                    Executive_Director__c, Executive_Director__r.Email,
                    npe01__One2OneContact__r.Email
                    FROM Account WHERE Id = :partnerID LIMIT 1];
            System.debug('PartnerSignup_Submitted > account: ' + partner);

            switch on renewal {

                when 'NEW' {
                    // update partner account
                    partner.Partner_Join_Year__c = System.today();
                    update partner;

                    // send email to partner
                    sendEmail(partner, isExecutiveDirector);

                    // publish 'SIGNUP' platform event
                    Partner_Event__e event = new Partner_Event__e();
                    event.Event_Type__c = 'SIGNUP';
                    event.Partner_ID__c = partnerID;
                    publishEvent(event);
                }

                when 'RENEW' {
                    // update partner account
                    partner.Renewed_Date__c = System.today();
                    partner.Renewed_By__c = partner.Executive_Director__c;
                    update partner;

                    // publish 'RENEWED' platform event
                    Partner_Event__e event = new Partner_Event__e();
                    event.Event_Type__c = 'RENEWED';
                    event.Partner_ID__c = partnerID;
                    publishEvent(event);
                }

            } // end switch

        } // end for

    } // end submitted

    static void publishEvent(Partner_Event__e event) {

        System.debug('PartnerSignup_Submitted > publishEvent: ' + event);
        Database.SaveResult result = EventBus.publish(event);

        if (result.isSuccess()) {
            System.debug('PartnerSignup_Submitted > event published: ' + event);
        } else {
            String errors = '';
            for(Database.Error err : result.getErrors()) {
                errors += 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage();
            }
            System.debug('PartnerSignup_Submitted > publishEvent - error: ' + errors);
        }

    } // end publishEvent

    static void sendEmail(Account partner, Boolean isExecutiveDirector) {

        System.debug('PartnerSignup_Submitted > sendEmail - partner: ' + partner + ', isExecutiveDirector: ' + isExecutiveDirector);

        // emails
        Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();

        // confirmation email of the partner signing up for the partner waitlist
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
        ID emailTemplateID_SUBMITTED = PartnerSignupController.getEmailTemplateID(emailTemplate_SUBMITTED);
        if (emailTemplateID_SUBMITTED != null) {
            message.setWhatId(partner.Id);
            message.setTemplateID(emailTemplateID_SUBMITTED);
            emails.add(message);
        }

        // if the executive director did not submit the signup form.
        if (isExecutiveDirector == false) {

            // email to the executive director for signing the partner agreements.
            Messaging.SingleEmailMessage message2 = new Messaging.SingleEmailMessage();

            // to email address
            message2.setToAddresses(new String[]{ execEmail });
            message2.setCcAddresses(new String[]{ primaryEmail });
            message2.setBccAddresses(new String[]{ bccEmail });

            // activity
            message2.setTargetObjectId(partner.Executive_Director__c);
            message2.setSaveAsActivity(true);

            // from email address from Org Wide Email
            if (fromEmailID != null) {
                message2.setOrgWideEmailAddressId(fromEmailID);
                message2.setUseSignature(false); // removes org-wide user's email signature
            } // otherwise email will be sent from current user

            ID emailTemplateID_SIGNATURES = PartnerSignupController.getEmailTemplateID(emailTemplate_SIGNATURES);
            if (emailTemplateID_SIGNATURES != null) {
                message2.setWhatId(partner.Id);
                message2.setTemplateID(emailTemplateID_SIGNATURES);
                emails.add(message2);
            }
        }

        // send emails
        System.debug('PartnerSignup_Submitted > sendEmail - email messages: ' + emails);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        System.debug('PartnerSignup_Submitted > sendEmail - results: ' + results);

    } // end sendEmail

} // end PartnerSignup_Submitted