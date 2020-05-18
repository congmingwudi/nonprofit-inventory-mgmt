global without sharing class PartnerAgreements_Approved {

    @InvocableMethod(label='Partner Agreements Approved')
    global static List<ID> partnerAgreementsApproved(List<ID> partnerIDs) {

        List<ID> approverIDs = new List<ID>();

        if (partnerIDs != null) {
            System.debug('PartnerAgreements_Approved > partnerIDs: ' + partnerIDs.size());

            for (ID partnerID : partnerIDs) {

                System.debug('PartnerAgreements_Approved > partnerID: ' + partnerID);

                // get partner account
                Account partner = [SELECT Id, Name,
                        Latest_Partner_Agreement__c, Latest_Liability_Waiver__c,
                        Executive_Director__c, Executive_Director__r.Email
                        FROM Account WHERE Id = :partnerID LIMIT 1
                ];

                // agreements
                List<ID> partnerAgreementIDs = new List<ID>();
                partnerAgreementIDs.add(partner.Latest_Partner_Agreement__c);
                partnerAgreementIDs.add(partner.Latest_Liability_Waiver__c);

                // sign partner agreements
                List<Partner_Agreement__c> paList = PartnerSignupController.signPartnerAgreements(partnerAgreementIDs);
                System.debug('PartnerAgreements_Approved > partner agreements signed: ' + paList);

                // check all agreements were signed ok
                if (partnerAgreementIDs.size() == paList.size()) {

                    // get approver of the partner agreements
                    Partner_Agreement__c pa = paList.get(0);
                    ID approverID = pa.Executive_Director__c;
                    approverIDs.add(approverID);
                }

            } // end for
        }

        return approverIDs;
        
    } // end partnerAgreementsApproved
    
} // end PartnerAgreements_Approved