/**
 * Created by ryan.cox on 1/27/20.
 */

public without sharing class PartnerAgreements_Create {

    @InvocableMethod(label='Create Partner Agreements' description='Creates current partner agreements for a partner account.')
    public static List<PartnerAgreements> createPartnerAgreements(List<PartnerAgreements> agreementsList) {

        List<PartnerAgreements> updatedAgreementsList = new List<PartnerAgreements>();

        for (PartnerAgreements agreements : agreementsList) {

            System.debug('PartnerAgreements_Create > agreements input: ' + agreements);

            // create partner agreements
            agreements = PartnerSignupController.createPartnerAgreements(agreements);
            System.debug('PartnerAgreements_Create > agreements output: ' + agreements);
            updatedAgreementsList.add(agreements);
        }

        return updatedAgreementsList;

    } // end createPartnerAgreements

} // end PartnerAgreements_Create