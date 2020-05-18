/**
 * Created by ryan.cox on 2/5/20.
 */

@isTest
private class PartnerSignup_Test {

    @isTest static void test_visualforce_controllers() {

        System.debug('PartnerSignup_Test > test_visualforce_controllers - start');

        // PartnerAgreementPDF
        System.debug('PartnerSignup_Test > test_visualforce_controllers - page: PartnerAgreementPDF');

        // visualforce page
        PageReference pageRef = Page.PartnerAgreementPDF;
        Test.setCurrentPage(pageRef);

        // add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', '100');
        String partnerAgreementID = PartnerSignupController.getPagePartnerAgreementID();
        System.debug('PartnerSignup_Test > partnerAgreementID: ' + partnerAgreementID);
        System.assertEquals(partnerAgreementID, '100');

        // PartnerSignupFlow_LightningOutAppPage
        System.debug('PartnerSignup_Test > test_visualforce_controllers - page: PartnerSignupFlow_LightningOutAppPage');

        // visualforce page
        pageRef = Page.PartnerSignupFlow_LightningOutAppPage;
        Test.setCurrentPage(pageRef);

        // add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', '100');
        ApexPages.currentPage().getParameters().put('renewal', 'RENEW');
        String partnerID = PartnerSignupController.getPagePartnerID();
        String renewal = PartnerSignupController.getPageRenewal();
        System.debug('PartnerSignup_Test > partnerID: ' + partnerID + ', renewal: ' + renewal);
        System.assertEquals(partnerID, '100');
        System.assertEquals(renewal, 'RENEW');

        // PartnerAgreementPDFDownload
        System.debug('PartnerSignup_Test > test_visualforce_controllers - page: PartnerAgreementPDFDownload');

        // visualforce page
        pageRef = Page.PartnerAgreementPDFDownload;
        Test.setCurrentPage(pageRef);

        // add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', '100');
        partnerAgreementID = PartnerSignupController.getPagePartnerAgreementID();
        System.debug('PartnerSignup_Test > partnerAgreementID: ' + partnerAgreementID);
        System.assertEquals(partnerAgreementID, '100');

        System.debug('PartnerSignup_Test > test_visualforce_controllers - end');

    } // end test_visualforce_controller

    @isTest static void test_locationInfo() {

        System.debug('PartnerSignup_Test > test_locationInfo - start');

        PartnerSignupController.LocationInfo loc = PartnerSignupController.getLocationInfo();

        System.debug('PartnerSignup_Test > test_locationInfo - end');

    } // end test_locationInfo

    @isTest static void test_createAccount() {

        Test.startTest();

        // test 1
        System.debug('PartnerSignup_Test > test_createAccount - start test 1');

        String accountName = 'Test Account';
        boolean accountExists = PartnerSignupController.accountExists(accountName);
        System.assert(accountExists == false);

        Account partner = new Account();
        partner.Name = 'Test Account';

        Contact exec = new Contact();
        exec.FirstName = 'Exec';
        exec.LastName = 'Test';
        exec.Email = 'exec@example.com';
        exec.MobilePhone = '111-111-1111';
        exec.npe01__WorkPhone__c = '111-111-1111';

        Contact primary = new Contact();
        primary.FirstName = 'Primary';
        primary.LastName = 'Test';
        primary.Email = 'primary@example.com';
        primary.MobilePhone = '111-111-1111';
        primary.npe01__WorkPhone__c = '111-111-1111';

        PartnerDetails partnerDetails = new PartnerDetails();
        partnerDetails.partner = partner;
        partnerDetails.executiveDirector = exec;
        partnerDetails.primaryContact = primary;
        partnerDetails.isExecutiveDirector = false;
        partnerDetails.isPrimaryContact = false;

        partnerDetails = PartnerSignupController.createAccount(partnerDetails);

        System.assert(partnerDetails.partner.Id != null, 'Partner Account not created');
        System.assert(partnerDetails.executiveDirector.Id != null, 'Executive Director not created');
        System.assert(partnerDetails.primaryContact.Id != null, 'Primary Contact not created');

        accountExists = PartnerSignupController.accountExists(accountName);
        System.assert(accountExists == true, 'Partner Account not created');

        Account account = PartnerSignupController.getAccountContacts(partnerDetails.partner.Id);
        System.assert(account != null, 'Partner Account not created');

        account = PartnerSignupController.getAccountDetails(partnerDetails.partner.Id);

        System.debug('PartnerSignup_Test > test_createAccount - end test 1');

        // test 2
        System.debug('PartnerSignup_Test > test_createAccount - start test 2');

        partnerDetails.partner.Id = null;
        partnerDetails.executiveDirector.Id = null;
        partnerDetails.primaryContact.Id = null;
        partnerDetails.isExecutiveDirector = true;
        partnerDetails.isPrimaryContact = true;

        partnerDetails = PartnerSignupController.createAccount(partnerDetails);

        System.assert(partnerDetails.partner.Id != null, 'Partner Account not created');
        System.assert(partnerDetails.executiveDirector.Id != null, 'Executive Director not created');
        System.assert(partnerDetails.primaryContact.Id != null, 'Primary Contact not created');

        System.debug('PartnerSignup_Test > test_createAccount - end test 2');

        // test 3
        System.debug('PartnerSignup_Test > test_createAccount - start test 3');
        partnerDetails.partner.Accept_Donations__c = true;
        partnerDetails = PartnerSignupController.updateAccount(partnerDetails);
        System.assert(partnerDetails.errorMessage == null, 'Partner Account not updated');
        System.debug('PartnerSignup_Test > test_createAccount - end test 3');

        // test 4 - PartnerSignup_Submitted.submitted (isExecutiveDirector == true, NEW)
        System.debug('PartnerSignup_Test > test_createAccount - start test 4');
        PartnerDetailsInvocable partnerDetailsInvocable = new PartnerDetailsInvocable();
        partnerDetailsInvocable.partnerID = partnerDetails.partner.Id;
        partnerDetailsInvocable.isExecutiveDirector = partnerDetails.isExecutiveDirector;
        partnerDetailsInvocable.renewal = 'NEW';
        List<PartnerDetailsInvocable> partnerDetailsList = new List<PartnerDetailsInvocable>();
        partnerDetailsList.add(partnerDetailsInvocable);
        PartnerSignup_Submitted.submitted(partnerDetailsList);
        System.debug('PartnerSignup_Test > test_createAccount - end test 4');

        // test 5 - PartnerSignup_Submitted.submitted (isExecutiveDirector == false, NEW)
        System.debug('PartnerSignup_Test > test_createAccount - start test 5');
        partnerDetailsInvocable.isExecutiveDirector = false;
        partnerDetailsInvocable.renewal = 'NEW';
        partnerDetailsList = new List<PartnerDetailsInvocable>();
        partnerDetailsList.add(partnerDetailsInvocable);
        PartnerSignup_Submitted.submitted(partnerDetailsList);
        System.debug('PartnerSignup_Test > test_createAccount - end test 5');

        // test 6 - PartnerSignup_Submitted.submitted (isExecutiveDirector == false, RENEW)
        System.debug('PartnerSignup_Test > test_createAccount - start test 5');
        partnerDetailsInvocable.isExecutiveDirector = false;
        partnerDetailsInvocable.renewal = 'RENEW';
        partnerDetailsList = new List<PartnerDetailsInvocable>();
        partnerDetailsList.add(partnerDetailsInvocable);
        PartnerSignup_Submitted.submitted(partnerDetailsList);
        System.debug('PartnerSignup_Test > test_createAccount - end test 5');

        Test.stopTest();

    } // end test_createAccount

    @isTest static void test_cancel() {

        Test.startTest();

        System.debug('PartnerSignup_Test > test_cancel - start test');

        // account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        // cancel
        List<PartnerDetailsInvocable> partnerDetailsList = new List<PartnerDetailsInvocable>();
        PartnerDetailsInvocable details = new PartnerDetailsInvocable();
        details.partnerID = account.Id;
        details.renewal = 'NEW';
        partnerDetailsList.add(details);
        PartnerSignup_Cancel.cancel(partnerDetailsList);

        System.debug('PartnerSignup_Test > test_cancel - end test');

        Test.stopTest();

    } // end test_other

    @isTest static void test_demographicsServed() {

        Test.startTest();

        // test 1
        System.debug('PartnerSignup_Test > test_demographicsServed - start test');

        Account partner = new Account();
        partner.Name = 'Test Account';
        insert partner;

        Integer numFamiliesServed = 20;
        String demographicList = '[{"RaceEthnicity":"African","PercentFamiliesServed":"50"},{"RaceEthnicity":"African American","PercentFamiliesServed":"50"}]';
        List<String> results = PartnerSignupController.createDemographicsServed(partner.Id, numFamiliesServed, demographicList);

        demographicList = '[{"RaceEthnicity":"African","PercentFamiliesServed":"50"},{"RaceEthnicity":"African American","PercentFamiliesServed":"30"},{"RaceEthnicity":"Caucasian","PercentFamiliesServed":"20"}]';
        results = PartnerSignupController.updateDemographicsServed(partner.Id, numFamiliesServed, demographicList);

        System.debug('PartnerSignup_Test > test_demographicsServed - end test');

        Test.stopTest();

    } // end test_demographicsServed

    @isTest static void test_other() {

        Test.startTest();

        // test - getCountyOptions

        System.debug('PartnerSignup_Test > test_other - start test: getCountyOptions');
        List<PartnerSignupController.Option> options = PartnerSignupController.getCountyOptions();
        System.assert(options != null && options.size() > 0, 'no county options returned');
        System.debug('PartnerSignup_Test > test_other - end test getCountyOptions');

        // test - insertFile

        System.debug('PartnerSignup_Test > test_other - start test: insertFile');
        Account account = new Account(Name = 'Test Account');
        insert account;
        ID parentID = account.Id;
        String fileName = 'test.txt';
        Blob content = Blob.valueOf('test content');
        String fileURL = PartnerSignupController.insertFile(parentID, fileName, content);
        System.debug('PartnerSignup_Test > test_other - end test: insertFile');

        Test.stopTest();

    } // end test_other

} // end PartnerSignup_Test