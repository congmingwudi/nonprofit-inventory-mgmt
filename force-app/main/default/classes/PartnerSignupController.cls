/**
 * Created by ryan.cox on 2019-11-16.
 */

public without sharing class PartnerSignupController {

    static String orgWideEmailName = 'Inventory_Mgmt'; //'WeeCycle';
    static String signByTitle = 'Executive Director';
    static String defaultSiteName = 'partners';

    // used by visualforce page that embeds the PartnerSignupFlowLightningOutApp
    public static String getPagePartnerID() {

        String partnerID;
        if (System.currentPageReference() != null) {
            partnerID = System.currentPageReference().getParameters().get('id');
        }
        System.debug('PartnerSignupController > getPagePartnerID: ' + partnerID);
        return partnerID;

    } // end getPagePartnerID

    // used by visualforce page that embeds the PartnerSignupFlowLightningOutApp
    public static String getPageRenewal() {

        String renewal = null;
        if (System.currentPageReference() != null) {
            renewal = System.currentPageReference().getParameters().get('renewal');
        }
        System.debug('PartnerSignupController > getPageRenewal: ' + renewal);
        return renewal;

    } // end getPageRenewal

    // used by visualforce page: PartnerAgreementPDFDownload
    public static String getPagePartnerAgreementID() {

        String partnerAgreementID;
        if (System.currentPageReference() != null) {
            partnerAgreementID = System.currentPageReference().getParameters().get('id');
        }
        System.debug('PartnerSignupController > getPagePartnerAgreementID: ' + partnerAgreementID);
        return partnerAgreementID;

    } // end getPagePartnerAgreementID

    // ------------ used by lightning component: PartnerSignup_Contact

    @AuraEnabled
    public static LocationInfo getLocationInfo() {

        System.debug('PartnerSignupController > getLocationInfo');
        Organization org = [SELECT Street, City, State, PostalCode FROM Organization];
        System.debug('PartnerSignupController > getLocationInfo - address: ' + org);

        LocationInfo loc = new LocationInfo();
        loc.fullAddress = org.Street + ', ' + org.City + ', ' + org.State + ' ' + org.PostalCode;
        loc.mapURL = 'https://maps.google.com/maps?q=' + EncodingUtil.urlEncode(loc.fullAddress, 'UTF-8');

        System.debug('PartnerSignupController > getLocationInfo - locationInfo: ' + loc);
        return loc;

    } // end getLocationInfo

    @AuraEnabled
    public static boolean accountExists(String accountName) {

        System.debug('PartnerSignupController > accountExists');
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        if (accounts.size() > 0) return true;
        else return false;

    } // end accountExists

    @AuraEnabled
    public static Account getAccountContacts(String accountID) {

        System.debug('PartnerSignupController > getAccountContacts - accountID: ' + accountID);
        Account account;
        List<Account> accounts = [SELECT Id, Name,
                BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Executive_Director__r.Id, Executive_Director__r.FirstName, Executive_Director__r.LastName,
                Executive_Director__r.Email, Executive_Director__r.MobilePhone, Executive_Director__r.npe01__WorkPhone__c,
                npe01__One2OneContact__r.Id, npe01__One2OneContact__r.FirstName, npe01__One2OneContact__r.LastName,
                npe01__One2OneContact__r.Email, npe01__One2OneContact__r.MobilePhone, npe01__One2OneContact__r.npe01__WorkPhone__c
        FROM Account WHERE Id = :accountID LIMIT 1];
        if (accounts.size() > 0) {
            account = accounts.get(0);
        }
        System.debug('PartnerSignupController > getAccountContacts - account: ' + account);
        return account;

    } // end getAccount

    @AuraEnabled
    public static List<Option> getCountyOptions() {

        System.debug('PartnerSignupController > getCountyOptions');
        String objName = 'Account';
        String fieldName = 'Counties_Served__c';
        SObject obj = Schema.getGlobalDescribe().get(objName).newSObject() ;
        List<Option> countyOptions = getPicklistValues(obj, fieldName);
        System.debug('PartnerSignupController > getCountyOptions: ' + countyOptions);
        return countyOptions;

    } // end getCountyOptions

    @AuraEnabled
    public static PartnerDetails createAccount(PartnerDetails partnerDetails) {

        System.debug('PartnerSignupController > createAccount - partnerDetails: ' + partnerDetails);

        try {
            // create Account
            Account partner = partnerDetails.partner;
            partner.Type = 'Partner - Waitlist';
            String recordTypeName = 'Organization';
            Id recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            partner.RecordTypeId = recordTypeID;
            insert partner;
            System.debug('PartnerSignupController > createAccount - partner account created: ' + partner);

            // executive director
            Contact exec = createContact('Executive Director', partnerDetails.executiveDirector, partner);
            partner.Executive_Director__c = exec.Id;

            // primary contact
            Contact primary;
            if (partnerDetails.isPrimaryContact) {
                primary = exec;
                partner.npe01__One2OneContact__c = primary.Id;
            } else {
                primary = createContact('Primary Contact', partnerDetails.primaryContact, partner);
                partner.npe01__One2OneContact__c = primary.Id;
            }

            // enrolled by
            if (partnerDetails.isExecutiveDirector) {
                // person submitting the form is the executive director
                partner.Enrolled_By__c = exec.Id;
            } else {
                // otherwise set to primary contact
                partner.Enrolled_By__c = primary.Id;
            }

            update partner;
            System.debug('PartnerSignupController > createAccount - partner account updated: ' + partner);

            partnerDetails.partner = partner;
            partnerDetails.executiveDirector = exec;
            partnerDetails.primaryContact = primary;

        } catch (Exception e) {
            System.debug('PartnerSignupController > createAccount - error: ' + e);
            partnerDetails.errorMessage = 'Error creating partner account: ' + e;
        }

        System.debug('PartnerSignupController > createAccount - returning partnerDetails: ' + partnerDetails);
        return partnerDetails;

    } // end createAccount

    private static Contact createContact(String role, Contact contact, Account partner) {

        System.debug('PartnerSignupController > createAccount - createContact: ' + contact);

        List<Contact> contacts = [SELECT Id FROM Contact WHERE FirstName = :contact.FirstName AND LastName = :contact.LastName AND Email = :contact.Email LIMIT 1];
        if (contacts.size() > 0) {
            // update contact
            Contact firstContact = contacts.get(0);
            contact.Id = firstContact.Id;
            update contact;
            System.debug('PartnerSignupController > createAccount - contact updated: ' + contact);

            // create an affiliation between the account and contact
            npe5__Affiliation__c affiliation = new npe5__Affiliation__c();
            affiliation.npe5__Contact__c = contact.Id;
            affiliation.npe5__Organization__c = partner.Id;
            affiliation.npe5__Role__c = role;
            affiliation.npe5__Status__c = 'Current';
            affiliation.npe5__StartDate__c = System.today();
            if (role == 'Executive Director') {
                affiliation.Executive_Director__c = true;
            }
            insert affiliation;
            System.debug('PartnerSignupController > createAccount - affiliation created: ' + affiliation);

        } else {
            // insert contact
            contact.AccountId = partner.Id;
            insert contact;
            System.debug('PartnerSignupController > createAccount - contact inserted: ' + contact);

            // account affiliation may be created automatically by a trigger between the account and contact
            // find and update this affiliation
            List<npe5__Affiliation__c> affiliations = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Contact__c = :contact.Id AND npe5__Organization__c = :partner.Id LIMIT 1];
            npe5__Affiliation__c affiliation;
            if (affiliations.size() > 0) {
                affiliation = affiliations.get(0);
            } else {
                // create affiliation if existing one is not found
                System.debug('PartnerSignupController > createContact - no affiliation found');
                affiliation = new npe5__Affiliation__c();
                affiliation.npe5__Contact__c = contact.Id;
                affiliation.npe5__Organization__c = partner.Id;
                affiliation.npe5__Status__c = 'Current';
                affiliation.npe5__StartDate__c = System.today();
            }
            affiliation.npe5__Role__c = role;
            affiliation.npe5__Primary__c = true; // since inserting new contact, account will be primary affiliation for this contact
            if (role == 'Executive Director') {
                affiliation.Executive_Director__c = true;
            }
            upsert affiliation;
            System.debug('PartnerSignupController > createAccount - affiliation upserted: ' + affiliation);
        }

        return contact;

    } // end createContact


    // ------------ used by lightning components: PartnerSignup_Contacts, PartnerSignup_Details

    @AuraEnabled
    public static PartnerDetails updateAccount(PartnerDetails partnerDetails) {

        System.debug('PartnerSignupController > updateAccount - partnerDetails: ' + partnerDetails);

        Account partner = partnerDetails.partner;
        
        try {

            if ((partnerDetails.executiveDirector != null) && (partnerDetails.primaryContact != null)) {

                // handle updating contacts, if changed
                List<npe5__Affiliation__c> affiliationsToUpdate = new List<npe5__Affiliation__c>();

                // executive director
                Contact exec = partnerDetails.executiveDirector;
                switch on partnerDetails.executiveDirectorAction {
                    when 'UPDATE' {
                        // update contact
                        update exec;
                        System.debug('PartnerSignupController > updateAccount - executive director updated: ' + exec);
                    }
                    when 'CREATE' {
                        // change previous executive director affiliation to not be executive director anymore
                        List<npe5__Affiliation__c> affiliations = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Organization__c = :partner.Id AND npe5__Role__c = 'Executive Director' LIMIT 1];
                        npe5__Affiliation__c affiliation;
                        if (affiliations.size() > 0) {
                            affiliation = affiliations.get(0);
                            affiliation.npe5__Role__c = '';
                            affiliation.Executive_Director__c = false;
                            affiliationsToUpdate.add(affiliation);
                        }

                        // create contact
                        exec.Id = null;
                        exec = createContact('Executive Director', exec, partner);
                        partner.Executive_Director__c = exec.Id;
                    }
                }
                partnerDetails.executiveDirector = exec;

                // primary contact
                Contact primary = partnerDetails.primaryContact;
                if (partnerDetails.isPrimaryContact) {
                    partner.npe01__One2OneContact__c = exec.Id;
                } else {
                    switch on partnerDetails.primaryContactAction {
                        when 'UPDATE' {
                            // update contact
                            update primary;
                            System.debug('PartnerSignupController > updateAccount - primary contact updated: ' + exec);
                        }
                        when 'CREATE' {
                            // change previous primary affiliation to not be primary anymore
                            List<npe5__Affiliation__c> affiliations = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Organization__c = :partner.Id AND npe5__Role__c = 'Primary Contact' LIMIT 1];
                            npe5__Affiliation__c affiliation;
                            if (affiliations.size() > 0) {
                                affiliation = affiliations.get(0);
                                affiliation.npe5__Role__c = '';
                                affiliationsToUpdate.add(affiliation);
                            }

                            // create contact
                            primary.Id = null;
                            primary = createContact('Primary Contact', primary, partner);
                            partner.npe01__One2OneContact__c = primary.Id;
                        }
                        when 'EXECUTIVE_DIRECTOR' {
                            // change previous primary affiliation to not be primary anymore
                            List<npe5__Affiliation__c> affiliations = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Organization__c = :partner.Id AND npe5__Role__c = 'Primary Contact' LIMIT 1];
                            npe5__Affiliation__c affiliation;
                            if (affiliations.size() > 0) {
                                affiliation = affiliations.get(0);
                                affiliation.npe5__Role__c = '';
                                affiliationsToUpdate.add(affiliation);
                            }
                        }
                    }
                }
                partnerDetails.primaryContact = primary;

                // update affiliations
                if (affiliationsToUpdate.size() > 0) {
                    update affiliationsToUpdate;
                }

            } // end if contacts included in the update

            // update Account
            update partner;
            System.debug('PartnerSignupController > updateAccount - partner account updated: ' + partner);

        } catch (Exception e) {
            System.debug('PartnerSignupController > updateAccount - error: ' + e);
            partnerDetails.errorMessage = 'Error updating partner account: ' + e;
        }

        return partnerDetails;

    } // end updateAccount


    // ------------ used by lightning component: PartnerSignup_Details

    @AuraEnabled
    public static Account getAccountDetails(String accountID) {

        System.debug('PartnerSignupController > getAccountDetails - accountID: ' + accountID);
        Account account;
        List<Account> accounts = [SELECT Id, Name, Website, Description, Tax_ID__c, Organization_Type__c, Counties_Served__c,
                Families_Receiving_Support__c, Items_Most_Needed__c, Restrictions__c, Other_Info__c,
                is501c3__c, Accept_Donations__c, Pick_Up_Items__c
        FROM Account WHERE Id = :accountID LIMIT 1];
        if (accounts.size() > 0) {
            account = accounts.get(0);
        }
        System.debug('PartnerSignupController > getAccountDetails - account: ' + account);
        return account;

    } // end getAccountDetails

    // getPicklistValues - returns a list of inner class Option
    private static List<Option> getPicklistValues(SObject obj, String field) {
        System.debug('PartnerSignupController > getPicklistValues - obj: ' + obj + ', field: ' + field);
        List<Option> options = new List<Option>();

        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType();

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        // Get a map of fields for the SObject
        Map< String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> pickListOptions = fieldMap.get(field).getDescribe().getPickListValues();

        // Add these values to the select option list
        for (Schema.PicklistEntry a: pickListOptions) {
            Option option = new Option();
            option.label = a.getLabel();
            option.value = a.getValue();
            if (a.isDefaultValue()) {
                option.defaultValue = true;
            }
            options.add(option);
        }

        System.debug('PartnerSignupController > getPicklistValues - values: ' + options);
        //options.sort();
        return options;

    } // getPicklistValues


    // ------------ used by InvocableMethod in PartnerAgreements_Create

    // create partner agreements for the partner account
    // two agreements will be created with the latest templates for the Partner Agreement and the Liability Waiver
    public static PartnerAgreements createPartnerAgreements(PartnerAgreements agreements) {

        System.debug('PartnerSignupController > createPartnerAgreements - agreements input: ' + agreements);

        String errorMessage = '';
        List<Partner_Agreement__c> toCreate = new List<Partner_Agreement__c>();

        // get latest partner agreement templates.
        // at least one template for each type "Partner Agreement" and "Liability Waiver" must be active.

        // latest "Partner Agreement" template
        String partnerAgreementTemplateID;
        List<Partner_Agreement_Template__c> templates = [SELECT Id FROM Partner_Agreement_Template__c
        WHERE Agreement_Type__c = 'Partner Agreement' AND Active__c = true AND Active_As_Of__c <= TODAY
        ORDER BY Active_As_Of__c DESC LIMIT 1];
        if (templates.size() > 0) {
            partnerAgreementTemplateID = templates.get(0).Id;
        } else {
            errorMessage += 'No active \'Partner Agreement\' template found. ';
            System.debug('PartnerSignupController > createPartnerAgreements - error: ' + errorMessage);
        }

        // latest "Liability Waiver" template
        String liabilityWaiverTemplateID;
        templates = [SELECT Id FROM Partner_Agreement_Template__c
        WHERE Agreement_Type__c = 'Liability Waiver' AND Active__c = true AND Active_As_Of__c <= TODAY
        ORDER BY Active_As_Of__c DESC LIMIT 1];
        if (templates.size() > 0) {
            liabilityWaiverTemplateID = templates.get(0).Id;
        } else {
            errorMessage += 'No active \'Liability Waiver\' template found. ';
            System.debug('PartnerSignupController > createPartnerAgreements - error: ' + errorMessage);
        }

        // check required inputs
        if (String.isBlank(agreements.renewal)
                || String.isBlank(agreements.partnerAccountID)
                || String.isBlank(agreements.executiveDirectorID)) {
            errorMessage += 'Missing input values. Values required for: \'renewal\', \'partnerAccountID\', \'executiveDirectorID\'. ';
        }

        ID approverID;
        if (agreements.renewal == 'RENEW') {
            approverID = getApprover();
            if (approverID == null) {
                errorMessage += 'Approver not found to sign agreements. ';
            }
        }

        if (String.isBlank(errorMessage)) {
            errorMessage = null;

            // partner agreement
            Partner_Agreement__c partnerAgreement = new Partner_Agreement__c();
            partnerAgreement.Renewal__c = agreements.renewal;
            partnerAgreement.Partner__c = agreements.partnerAccountID;
            partnerAgreement.Partner_Executive_Director__c = agreements.executiveDirectorID;
            partnerAgreement.Partner_Agreement_Template__c = partnerAgreementTemplateID;

            if (agreements.renewal == 'RENEW') {
                partnerAgreement.Renewal__c = 'RENEW';
                partnerAgreement.Executive_Director__c = approverID;
                partnerAgreement.Date_Signed_By_Executive_Director__c = System.now();
            }

            toCreate.add(partnerAgreement);

            // liability waiver
            Partner_Agreement__c liabilityWaiver = new Partner_Agreement__c();
            liabilityWaiver.Renewal__c = agreements.renewal;
            liabilityWaiver.Partner__c = agreements.partnerAccountID;
            liabilityWaiver.Partner_Executive_Director__c = agreements.executiveDirectorID;
            liabilityWaiver.Partner_Agreement_Template__c = liabilityWaiverTemplateID;

            if (agreements.renewal == 'RENEW') {
                liabilityWaiver.Renewal__c = 'RENEW';
                liabilityWaiver.Executive_Director__c = approverID;
                liabilityWaiver.Date_Signed_By_Executive_Director__c = System.now();
            }

            toCreate.add(liabilityWaiver);

            // insert agreements
            insert toCreate;

            // get the generated names and set partner latest agreements
            Account partner = new Account(Id = agreements.partnerAccountID);

            List<String> ids = new List<String>();
            for (Partner_Agreement__c a : toCreate) {
                ids.add(a.Id);
            }

            List<Partner_Agreement__c> created = [SELECT Id, Name, Agreement_Type__c FROM Partner_Agreement__c WHERE Id IN :ids];
            for (Partner_Agreement__c a : created) {
                if (a.Agreement_Type__c == 'Partner Agreement') {
                    agreements.partnerAgreementID = a.Id;
                    agreements.partnerAgreementName = a.Name;
                    partner.Latest_Partner_Agreement__c = a.Id;
                } else if (a.Agreement_Type__c == 'Liability Waiver') {
                    agreements.liabilityWaiverID = a.Id;
                    agreements.liabilityWaiverName = a.Name;
                    partner.Latest_Liability_Waiver__c = a.Id;
                }
            }

            // update partner record w/ latest agreements
            update partner;
            System.debug('PartnerSignupController > createPartnerAgreements - partner updated: ' + partner);

        }
        agreements.errorMessage = errorMessage;

        System.debug('PartnerSignupController > createPartnerAgreements - agreements response: ' + agreements);
        return agreements;

    } // end createPartnerAgreements


    // ------------ used by lightning component: PartnerSignup_Agreement

    // returns Partner Agreement by Name
    @AuraEnabled
    public static PartnerAgreementDetails getPartnerAgreement(String partnerAgreementName) {

        System.debug('PartnerSignupController > getPartnerAgreement - name: ' + partnerAgreementName);

        PartnerAgreementDetails paDetails;

        if (partnerAgreementName != null) {
            List<Partner_Agreement__c> pas = [SELECT Id, Name, Partner__r.Id, Partner__r.Name, Partner_Agreement_Template__r.Full_Title__c
                    , Partner_Agreement_Template__r.Before_Behalf_Of__c, Behalf_Of__c, Partner_Agreement_Template__r.Body__c
                    , Partner_Agreement_Template__r.Footer__c, Date_Created__c, Date_Signed_By_Partner__c
                    , Status__c, Agreement_Type__c, Partner_Executive_Director__r.Name
            FROM Partner_Agreement__c WHERE Name = :partnerAgreementName LIMIT 1];
            if (pas.size() > 0) {
                Partner_Agreement__c pa = pas.get(0);
                paDetails = new PartnerAgreementDetails();
                paDetails.partnerAgreement = pa;
                paDetails.siteName = getSiteName();
                paDetails.downloadFileName = getPartnerAgreementFilename(pa);
            }
        }

        System.debug('PartnerSignupController > PartnerAgreementDetails: ' + paDetails);
        return paDetails;

    } // end getPartnerAgreement

    public static String getPartnerAgreementFilename(Partner_Agreement__c pa) {
        String timestamp = DateTimeFormatUtil.getDateTimeForFilename();
        String fileName = 'WeeCycle_' + pa.Agreement_Type__c + '_' + pa.Partner__r.Name + '_' + timestamp;

        // make sure file name is not longer than 80 characters, including file extension. this is a Salesforce limit.
        // file name without extension can be no longer than 76. the file extension '.pdf' is the other 4 characters.
        if (fileName.length() > 76) {
            fileName = fileName.substring(0,76);
        }

        return fileName + '.pdf';
    } // getPartnerAgreementFilename

    @AuraEnabled
    public static PartnerAgreementDetails updatePartnerAgreementSigned(PartnerAgreementDetails partnerAgreementDetails) {

        System.debug('PartnerSignupController > partnerAgreementSigned - partnerAgreementDetails: ' + partnerAgreementDetails);

        DateTime signedDate = System.now();
        String partnerAgreementID = partnerAgreementDetails.partnerAgreementID;
        String renewal = partnerAgreementDetails.renewal;

        // update partner agreement
        Partner_Agreement__c pa = new Partner_Agreement__c(Id = partnerAgreementID);
        pa.Date_Signed_By_Partner__c = signedDate;
        pa.Status__c = 'Partner Signed';
        update pa;
        partnerAgreementDetails.signedByPartnerDate = signedDate;

        System.debug('PartnerSignupController > partnerAgreementSigned - renewal: ' + renewal);

        /* not needed because signing agreement when created, for renewal
        // for renewal, sign agreement w/ approver when partner signs
        if (renewal == 'RENEW') {
            List<ID> paIDs = new List<ID>();
            paIDs.add(partnerAgreementID);
            try {
                signPartnerAgreements(paIDs);
            } catch (Exception e) {
                System.debug('PartnerSignupController > partnerAgreementSigned - error: ' + e);
                partnerAgreementDetails.errorMessage = e.getMessage();
            }
        }
        */

        return partnerAgreementDetails;

    } // end partnerAgreementSigned


    // ------------ used by InvocableMethod in PartnerAgreements_Approved

    public static ID getApprover() {

        // find internal user to sign partner agreements and approve partner accounts.
        // this user will be set as the Executive Director on the partner agreement.
        ID approverID;

        List<User> users = [SELECT Id, Name, Title, Signature__c FROM User WHERE Title = :signByTitle LIMIT 1];
        if (users.size() > 0) {
            User user = users.get(0);
            System.debug('PartnerSignupController > getApprover - user found: ' + user);

            // check signature
            if (user.Signature__c == null) {
                // throw custom UserNotFoundException
                String errorMsg = 'user, ' + user.Name + ', found with title \'' + signByTitle + '\' but has no signature to sign agreements';
                System.debug('PartnerSignupController > getApprover - error: ' + errorMsg);
                UserNotFoundException ex = new UserNotFoundException(errorMsg);
                throw ex;
            }

            approverID = user.Id;

        } else {
            // throw custom UserNotFoundException
            String errorMsg = 'no user found with title \'' + signByTitle + '\' to sign agreements';
            System.debug('PartnerSignupController > getApprover - error: ' + errorMsg);
            UserNotFoundException ex = new UserNotFoundException(errorMsg);
            throw ex;
        }

        return approverID;

    } // end getApprover

    // sign partner agreements by WeeCycle user and mark as 'Completed'
    public static List<Partner_Agreement__c> signPartnerAgreements(List<ID> partnerAgreementIDs) {

        System.debug('PartnerSignupController > signPartnerAgreements - partnerAgreementIDs: ' + partnerAgreementIDs);

        ID approverID = getApprover();

        List<Partner_Agreement__c> paList = new List<Partner_Agreement__c>();

        if ((partnerAgreementIDs != null) && (partnerAgreementIDs.size() > 0) && (approverID != null)) {

            // update partner agreements
            for (ID paID : partnerAgreementIDs) {
                Partner_Agreement__c pa = new Partner_Agreement__c(Id = paID);
                pa.Executive_Director__c = approverID;
                pa.Date_Signed_By_Executive_Director__c = System.now();
                pa.Status__c = 'Completed';
                paList.add(pa);
            }
            update paList;
            System.debug('PartnerSignupController > signPartnerAgreements - agreements signed: ' + paList);
        }

        return paList;

    } // end signPartnerAgreement


    // ------------ used by lightning component: PartnerSignup_Demographics

    @AuraEnabled
    public static List<String> createDemographicsServed(String accountID, Integer numFamiliesServed, String demographicList) {
        System.debug('PartnerSignupController > createDemographicsServed - accountID: ' + accountID
                + ', numFamiliesServed: ' + numFamiliesServed  + ', demographicList: ' + demographicList);

        // update Account num families served
        Account account = new Account(Id=accountID);
        account.Families_Receiving_Support__c = Decimal.valueOf(numFamiliesServed);
        update account;

        // deserialize demographicList json
        List<Object> oList = (List<Object>)JSON.deserializeUntyped(demographicList);
        //System.debug('PartnerSignupController > createDemographicsServed - demographicList: ' + oList + ', list size: ' + oList.size());

        List<Demographic_Served__c> demographicServedList = new List<Demographic_Served__c>();
        for (Integer i = 0; i < oList.size(); ++i) {

            Object o = oList.get(i);
            //System.debug('PartnerSignupController > createDemographicsServed - demographic: ' + o);

            Map<String, Object> m = (Map<String, Object>) o;

            String raceEthnicity = (String) m.get('RaceEthnicity');
            Integer percentFamiliesServed = Integer.valueOf(m.get('PercentFamiliesServed'));
            //Integer numFamiliesServed = Integer.valueOf(m.get('NumFamiliesServed'));
            System.debug('PartnerSignupController > createDemographicsServed - raceEthnicity: ' + raceEthnicity + ', percentFamiliesServed: ' + percentFamiliesServed);

            // create a Demographic_Served__c record
            Demographic_Served__c demographicServed = new Demographic_Served__c();
            demographicServed.Partner_Organization__c = accountID;
            demographicServed.Race_Ethnicity__c = raceEthnicity;
            demographicServed.Percent_Served__c = percentFamiliesServed;
            demographicServedList.add(demographicServed);

        } // for oList

        //System.debug('PartnerSignupController > createDemographicsServed - demographicServedList: ' + demographicServedList);
        insert demographicServedList;

        List<String> responseList = new List<String>();
        responseList.add('success');
        return responseList;

    } // end createDemographicsServed

    @AuraEnabled
    public static List<String> updateDemographicsServed(String accountID, Integer numFamiliesServed, String demographicList) {
        System.debug('PartnerSignupController > updateDemographicsServed - accountID: ' + accountID
                + ', numFamiliesServed: ' + numFamiliesServed  + ', demographicList: ' + demographicList);

        // update Account num families served
        Account account = new Account(Id=accountID);
        account.Families_Receiving_Support__c = Decimal.valueOf(numFamiliesServed);
        update account;

        // deserialize demographicList json
        List<Object> oList = (List<Object>)JSON.deserializeUntyped(demographicList);
        //System.debug('PartnerSignupController > updateDemographicsServed - demographicList: ' + oList + ', list size: ' + oList.size());

        // map of existing race/ethnicity : Demographic_Served__c
        List<Demographic_Served__c> demographicServedList = [SELECT Id, Race_Ethnicity__c, Percent_Served__c FROM Demographic_Served__c WHERE Partner_Organization__c=:accountID];
        Map<String, Demographic_Served__c> demographicMap = new Map<String, Demographic_Served__c>();
        for (Demographic_Served__c d : demographicServedList) {
            demographicMap.put(d.Race_Ethnicity__c, d);
        }

        // upsert existing Demographic_Served__c records
        List<Demographic_Served__c> upsertList = new List<Demographic_Served__c>();
        for (Integer i = 0; i < oList.size(); ++i) {

            Object o = oList.get(i);
            //System.debug('PartnerSignupController > updateDemographicsServed - demographic: ' + o);

            Map<String, Object> m = (Map<String, Object>) o;

            String raceEthnicity = (String) m.get('RaceEthnicity');
            Integer percentFamiliesServed = Integer.valueOf(m.get('PercentFamiliesServed'));
            //Integer numFamiliesServed = Integer.valueOf(m.get('NumFamiliesServed'));
            System.debug('PartnerSignupController > updateDemographicsServed - raceEthnicity: ' + raceEthnicity + ', percentFamiliesServed: ' + percentFamiliesServed);

            Demographic_Served__c d = demographicMap.get(raceEthnicity);
            if (d != null) {
                // update existing demographic
                d.Percent_Served__c = percentFamiliesServed;
                upsertList.add(d);
            }  else {
                // create new demographic
                if (percentFamiliesServed > 0) {
                    d = new Demographic_Served__c(Partner_Organization__c = accountID, Race_Ethnicity__c = raceEthnicity, Percent_Served__c = percentFamiliesServed);
                    upsertList.add(d);
                }
            }

        } // for oList

        //System.debug('PartnerSignupController > updateDemographicsServed - upsertList: ' + upsertList);
        upsert upsertList;

        List<String> responseList = new List<String>();
        responseList.add('success');
        return responseList;

    } // end updateDemographicsServed


    // ------------ utility methods used by InvocableMethods in PartnerAgreements_Submitted, PartnerAgreements_StorePDFs

    public static ID getOrgWideEmailID() {

        ID orgWideEmailID;

        // email address from Org Wide Email Address
        List<OrgWideEmailAddress> orgWideEmailAddresses = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName = :orgWideEmailName LIMIT 1];
        if (orgWideEmailAddresses.size() > 0) {
            OrgWideEmailAddress orgWideEmail = orgWideEmailAddresses.get(0);
            System.debug('PartnerSignupController > getOrgWideEmailID - orgWideEmail: ' + orgWideEmail);
            orgWideEmailID = orgWideEmail.Id;
        } else {
            // otherwise email will be sent from current user
            System.debug('PartnerSignupController > getOrgWideEmailID - no Org Wide Email configured for name: ' + orgWideEmailName + '. Using current user email: ' + UserInfo.getUserEmail());
        }

        return orgWideEmailID;

    } // end getOrgWideEmailID

    public static ID getEmailTemplateID(String emailTemplateName) {

        ID emailTemplateID;

        // find email template
        List<EmailTemplate> emailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        if (emailTemplates.size() > 0) {
            EmailTemplate emailTemplate = emailTemplates.get(0);
            System.debug('PartnerSignupController > getEmailTemplateID - email template found: ' + emailTemplate);
            emailTemplateID = emailTemplate.Id;
        } else {
            System.debug('PartnerSignupController > getEmailTemplateID - no email template configured with name: ' + emailTemplateName);
        }

        return emailTemplateID;

    } // end getEmailTemplateID

    public static String getSiteName() {

        String site = defaultSiteName;
        //String networkID = Network.getNetworkId();
        //System.debug('PartnerSignupController > getSiteName - networkID: ' + networkID);
        // if (networkID != null) {
        //     site = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :networkID].UrlPathPrefix;
        // }
        System.debug('PartnerSignupController > getSiteName - site: ' + site);
        return site;

    } // end getSiteName

    public static String getSiteURL() {
        String siteName = getSiteName();
        Site site = [SELECT Id FROM Site WHERE Name = :siteName];
        SiteDetail siteDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :site.Id];
        String siteURL = siteDetail.SecureUrl;
        System.debug('PartnerSignupController > getSiteURL - siteURL: ' + siteURL);
        return siteURL;
    } // end getSiteURL

    public static String insertFile(ID parentID, String fileName, Blob content) {

        System.debug('PartnerSignupController > insertFile - parentID: ' + parentID + ', fileName: ' + fileName);

        String fileURL; // returns shareable public link to the stored file

        // insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName; //File name with extension
        cVersion.Origin = 'C'; //C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach.OwnerId; //Owner of the file
        cVersion.Title = fileName; //Name of the file
        cVersion.VersionData = content; //File content
        insert cVersion;
        System.debug('PartnerSignupController > insertFile - file inserted: ' + fileName);

        // get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id].ContentDocumentId;

        // insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = parentID;
        cDocLink.ShareType = 'I'; // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers'; // AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        System.debug('PartnerSignupController > insertFile - ContentDocumentLink inserted: ' + cDocLink);

        // generate link shareable link to the file
        ContentDistribution cd = new ContentDistribution();
        cd.Name = cVersion.Title;
        cd.ContentVersionId = cVersion.Id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;

        cd = [SELECT Id, DistributionPublicUrl, Password FROM ContentDistribution WHERE Id = :cd.Id LIMIT 1];
        System.debug('PartnerSignupController > insertFile - ContentDistribution inserted: ' + cd);
        fileURL = cd.DistributionPublicUrl;

        return fileURL;

    } // end insertFile


    // ------------ inner classes used by the AuraEnabled methods as input/output types

    // Option - inner class for picklist/selection fields
    public class Option {
        @AuraEnabled
        String label {get;set;}
        @AuraEnabled
        String value {get;set;}
        @AuraEnabled
        Boolean defaultValue {get;set;}
    }

    // PartnerAgreementDetails - inner class
    public class PartnerAgreementDetails {
        @AuraEnabled
        public String renewal {get;set;} // NEW or RENEW

        @AuraEnabled
        public ID partnerAgreementID {get;set;}

        @AuraEnabled
        public Partner_Agreement__c partnerAgreement {get;set;}

        @AuraEnabled
        public String siteName {get;set;}

        @AuraEnabled
        public String downloadFileName {get;set;}

        @AuraEnabled
        public DateTime signedByPartnerDate {get;set;}

        @AuraEnabled
        public String errorMessage {get;set;}
    }

    // LocationInfo - inner class
    public class LocationInfo {
        
        @AuraEnabled
        public String fullAddress {get;set;}

        @AuraEnabled
        public String mapURL {get;set;}
    }

} // end PartnerSignupController