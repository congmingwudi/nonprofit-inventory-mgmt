/**
 * Created by ryan.cox on 1/27/20.
 */

@isTest
private class PartnerAgreements_Test {

    @isTest static void test() {

        Test.startTest();

        System.debug('PartnerAgreements_Test > test - start: createPartnerAgreements');

        // account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        // executive director
        Contact exec = new Contact();
        exec.AccountId = account.Id;
        exec.FirstName = 'Exec';
        exec.LastName = 'Test';
        exec.Email = 'exec@example.com';
        exec.MobilePhone = '111-111-1111';
        exec.npe01__WorkPhone__c = '111-111-1111';
        insert exec;

        // primary contact
        Contact primary = new Contact();
        primary.AccountId = account.Id;
        primary.FirstName = 'Primary';
        primary.LastName = 'Test';
        primary.Email = 'primary@example.com';
        primary.MobilePhone = '111-111-1111';
        primary.npe01__WorkPhone__c = '111-111-1111';
        insert primary;

        account.Executive_Director__c = exec.Id;
        account.npe01__One2OneContact__c = primary.Id;
        update account;

        //String partnerName = 'T4';
        //Account account = [SELECT Id, Executive_Director__c FROM Account WHERE Name = :partnerName LIMIT 1];

        // partner agreement templates
        Partner_Agreement_Template__c partnerAgreementTemplate = new Partner_Agreement_Template__c();
        partnerAgreementTemplate.Agreement_Type__c = 'Partner Agreement';
        partnerAgreementTemplate.Active__c = true;
        partnerAgreementTemplate.Active_As_Of__c = System.today();

        Partner_Agreement_Template__c waiverTemplate = new Partner_Agreement_Template__c();
        waiverTemplate.Agreement_Type__c = 'Liability Waiver';
        waiverTemplate.Active__c = true;
        waiverTemplate.Active_As_Of__c = System.today();

        List<Partner_Agreement_Template__c> templates = new List<Partner_Agreement_Template__c>();
        templates.add(partnerAgreementTemplate);
        templates.add(waiverTemplate);
        insert templates;

        PartnerAgreements agreements = new PartnerAgreements();
        agreements.renewal = 'NEW';
        agreements.partnerAccountID = account.Id;
        agreements.executiveDirectorID = account.Executive_Director__c;

        List<PartnerAgreements> agreementsList = new List<PartnerAgreements>();
        agreementsList.add(agreements);

        agreementsList = PartnerAgreements_Create.createPartnerAgreements(agreementsList);
        System.debug('PartnerAgreements_Test > test_createPartnerAgreements - agreementsList: ' + agreementsList);

        System.assertEquals(agreementsList.size(), 1);

        for (PartnerAgreements a : agreementsList) {
            System.assert(a.partnerAgreementName != null, 'Partner Agreement Name is null');

            PartnerSignupController.PartnerAgreementDetails partnerAgreementDetails = PartnerSignupController.getPartnerAgreement(a.partnerAgreementName);
            System.debug('PartnerAgreements_Test > test_createPartnerAgreements - partnerAgreementDetails returned: ' + partnerAgreementDetails);
            System.assert(partnerAgreementDetails.partnerAgreement != null, 'Partner Agreement not found');

            // test updatePartnerAgreementSigned
            PartnerSignupController.PartnerAgreementDetails details;
            DateTime dateSigned;

            details = new PartnerSignupController.PartnerAgreementDetails();
            details.partnerAgreementID = a.partnerAgreementID;
            details.renewal = 'NEW';
            details = PartnerSignupController.updatePartnerAgreementSigned(details);
            dateSigned = details.signedByPartnerDate;
            System.debug('PartnerAgreements_Test > test_createPartnerAgreements - updatePartnerAgreementSigned dateSigned: ' + dateSigned);
            System.assert(dateSigned != null, 'Partner Agreement dateSigned not set');

            PartnerSignupController.PartnerAgreementDetails liabilityWaiver = PartnerSignupController.getPartnerAgreement(a.liabilityWaiverName);
            System.debug('PartnerAgreements_Test > test_createPartnerAgreements - partnerAgreementDetails returned: ' + partnerAgreementDetails);
            System.assert(partnerAgreementDetails.partnerAgreement != null, 'Liability Waiver not found');

            // test updatePartnerAgreementSigned
            details = new PartnerSignupController.PartnerAgreementDetails();
            details.partnerAgreementID = a.liabilityWaiverID;
            details.renewal = 'RENEW';
            details = PartnerSignupController.updatePartnerAgreementSigned(details);
            dateSigned = details.signedByPartnerDate;
            System.debug('PartnerAgreements_Test > test_createPartnerAgreements - updatePartnerAgreementSigned dateSigned: ' + dateSigned);
            System.assert(dateSigned != null, 'Partner Agreement dateSigned not set');
        }

        System.debug('PartnerAgreements_Test > test - end: createPartnerAgreements');

        // test partnerAgreementsApproved
        System.debug('PartnerAgreements_Test > test - start: partnerAgreementsApproved');

        String signByTitle = 'Executive Director';
        List<User> users = [SELECT Id, Name, Title, Signature__c FROM User WHERE Title = :signByTitle LIMIT 1];
        if (users.size() > 0) {
            User user = users.get(0);
            System.debug('PartnerAgreements_Test > test - user found: ' + user);

            // check signature
            if (user.Signature__c == null) {
                user.Signature__c = 'test signature';
                update user;
            }
            System.debug('PartnerAgreements_Test > test - user updated: ' + user);
        }

        try {
            List<ID> partnerIDs = new List<ID>();
            partnerIDs.add(account.Id);
            PartnerAgreements_Approved.partnerAgreementsApproved(partnerIDs);
        } catch (UserNotFoundException e) {
            System.debug('PartnerAgreements_Test > test - exception: ' + e);
        }

        System.debug('PartnerAgreements_Test > test - end: partnerAgreementsApproved');

        // test storePDFs
        System.debug('PartnerAgreements_Test > test - start: storePDFs');

        List<PartnerEventData> partnerEvents = new List<PartnerEventData>();

        PartnerEventData eventData1 = new PartnerEventData();
        eventData1.eventType = 'APPROVED';
        eventData1.partnerAccountID = account.Id;
        partnerEvents.add(eventData1);

        PartnerEventData eventData2 = new PartnerEventData();
        eventData2.eventType = 'RENEWED';
        eventData2.partnerAccountID = account.Id;
        partnerEvents.add(eventData2);

        PartnerAgreements_StorePDFs.partnerAgreementsStorePDFs(partnerEvents);

        System.debug('PartnerAgreements_Test > test - end: storePDFs');

        // test createPartnerAgreements - RENEW
        System.debug('PartnerAgreements_Test > test - start: createPartnerAgreements - RENEW ');

        agreements = new PartnerAgreements();
        agreements.renewal = 'RENEW';
        agreements.partnerAccountID = account.Id;
        agreements.executiveDirectorID = account.Executive_Director__c;

        agreementsList = new List<PartnerAgreements>();
        agreementsList.add(agreements);

        agreementsList = PartnerAgreements_Create.createPartnerAgreements(agreementsList);
        System.debug('PartnerAgreements_Test > test_createPartnerAgreements - agreementsList: ' + agreementsList);

        System.debug('PartnerAgreements_Test > test - end: createPartnerAgreements - RENEW ');

        // test renewalRequest
        System.debug('PartnerAgreements_Test > test - start: renewalRequest');

        List<PartnerDetailsInvocable> partnerDetailsList = new List<PartnerDetailsInvocable>();
        PartnerDetailsInvocable details = new PartnerDetailsInvocable();
        details.partnerID = account.Id;
        partnerDetailsList.add(details);
        PartnerRenewal_SendRequest.renewalRequest(partnerDetailsList);

        System.debug('PartnerAgreements_Test > test - end: renewalRequest');

        // test partner agreements signature request

        System.debug('PartnerAgreements_Test > test - start: signatureRequest');
        PartnerAgreements_SignatureRequest.signatureRequest(partnerDetailsList);

        System.debug('PartnerAgreements_Test > test - end: signatureRequest');

        Test.stopTest();

    } // end test

    @isTest static void test_createPartnerAgreementsErrors() {

        Test.startTest();

        System.debug('PartnerAgreements_Test > test_createPartnerAgreementsErrors - start test');

        // test with no active partner agreement templates
        // and no required inputs
        PartnerAgreements agreements = new PartnerAgreements();
        agreements.renewal = null;
        agreements.partnerAccountID = null;
        agreements.executiveDirectorID = null;

        List<PartnerAgreements> agreementsList = new List<PartnerAgreements>();
        agreementsList.add(agreements);

        agreementsList = PartnerAgreements_Create.createPartnerAgreements(agreementsList);
        System.debug('PartnerAgreements_Test > test_createPartnerAgreementsErrors - agreementsList: ' + agreementsList);

        System.assertEquals(agreementsList.size(), 1);

        for (PartnerAgreements a : agreementsList) {
            System.assert(a.errorMessage != null, 'createPartnerAgreements should have produced an errorMessage');
        }

        System.debug('PartnerAgreements_Test > test_createPartnerAgreementsErrors - end');

        Test.stopTest();

    } // end test_createPartnerAgreements


} // end PartnerAgreements_Test