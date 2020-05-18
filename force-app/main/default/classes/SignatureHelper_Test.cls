/**
 * Created by ryan.cox on 2/20/20.
 */

@isTest
private with sharing class SignatureHelper_Test {

    @isTest static void test_saveSign_User() {

        // test storing signature for User record
        System.debug('SignatureHelper_Test >> test_saveSign_User > start');

        // user
        User user = createTestUser();

        // signature
        String signatureContent = getImageContent();

        System.RunAs(user) {
            Test.startTest();

            ID recordID = user.Id;
            SignatureHelper.saveSign(signatureContent, recordID);

            Test.stopTest();
        }

        System.debug('SignatureHelper_Test >> test_saveSign_User > end');

    } // end test_saveSign_User

    @isTest static void test_saveSign_PartnerAgreement() {

        // test storing signature for Partner_Agreement__c record

        // Partner Agreement
        Partner_Agreement__c pa = createPartnerAgreement();

        // signature
        String signatureContent = getImageContent();

        Test.startTest();

        ID recordID = pa.Id;
        SignatureHelper.saveSign(signatureContent, recordID);

        Test.stopTest();

        System.debug('SignatureHelper_Test >> test_saveSign_PartnerAgreement > end');
    }

    public static User createTestUser() {

        String randomString = generateRandomString(10);
        String username = randomString + '@test.org';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User(Alias = 'testuser', Email=username, UserName=username,
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles' );
        insert user;
        System.debug('SignatureHelper_Test >> createTestUser > user created: ' + user);
        return user;

    } // end createTestUser

    public static String generateRandomString(Integer len) {

        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String[] result = new String[len];
        Integer idx = 0;

        while(idx < len) {
            Integer chr = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            result[idx++] = chars.substring(chr, chr+1);
        }
        return String.join(result,'');

    } // end generateRandomString

    public static Partner_Agreement__c createPartnerAgreement() {

        // account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        // partner agreement template
        Partner_Agreement_Template__c paTemplate = new Partner_Agreement_Template__c();
        paTemplate.Agreement_Type__c = 'Partner Agreement';
        paTemplate.Active__c = true;
        paTemplate.Active_As_Of__c = System.today();
        insert paTemplate;

        // partner agreement
        Partner_Agreement__c pa = new Partner_Agreement__c();
        pa.Partner__c = account.Id;
        pa.Partner_Agreement_Template__c = paTemplate.Id;
        insert pa;

        System.debug('SignatureHelper_Test >> createPartnerAgreement > partner agreement created: ' + pa);
        return pa;

    } // end createPartnerAgreement


    public static String getImageContent() {
        return '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';
    }


} // end SignatureHelper_Test