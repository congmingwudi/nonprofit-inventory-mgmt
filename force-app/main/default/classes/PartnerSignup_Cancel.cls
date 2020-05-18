/**
 * Created by ryan.cox on 2/15/20.
 */

global without sharing class PartnerSignup_Cancel {

    @InvocableMethod(label='Partner Signup Canceled')
    global static void cancel(List<PartnerDetailsInvocable> partnerDetailsList) {

        for (PartnerDetailsInvocable partnerDetails : partnerDetailsList) {

            System.debug('PartnerSignup_Cancel > partnerDetails: ' + partnerDetails);
            String partnerID = partnerDetails.partnerID;
            String renewal = partnerDetails.renewal;

            if (renewal == 'NEW') {
                // delete partner account
                Account account = new Account(Id = partnerID);
                delete account;
                System.debug('PartnerSignup_Submitted > account deleted: ' + account);
            }

        } // end for

    } // end cancel

} // end PartnerSignup_Cancel