@isTest
private class GearOrderDemographicsController_Test { 

    @isTest static void test_getGearOrder() {
        
        System.debug('GearOrderDemographicsController_Test >> test_getGearOrder > start');
        
        List<Gear_Order__c> orders = null;
        
        // *** test getGearOrder
        
        // test w/ orderID
        String orderID = '1';
        String orderName = null;
        orders = GearOrderDemographicsController.getGearOrder(orderID, orderName);
        System.debug('GearOrderDemographicsController_Test >> test_getGearOrder - orders 1: ' + orders);
                
        // test w/ orderName
        orderID = null;
        orderName = '1';
        orders = GearOrderDemographicsController.getGearOrder(orderID, orderName); 
        System.debug('GearOrderDemographicsController_Test >> test_getGearOrder - orders 2: ' + orders);

    } // end test_getGearOrder     
    
    @isTest static void test_getPicklistValues() { 
        
        System.debug('GearOrderDemographicsController_Test >> test_getPicklistValues > start');
        
        SObject obj = new Gear_Order_Demographic__c();
        String field = 'Child_Gender__c';
        List<GearOrderDemographicsController.Option> options = GearOrderDemographicsController.getPicklistValues(obj, field); 
        System.debug('GearOrderDemographicsController_Test >> test_getPicklistValues > options: ' + options);
        
    } // end test_getPicklistValues     
    
    @isTest static void test_crudGearOrderDemographics() { 
        
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderDemographics > start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;

        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;  
        String orderID = order.Id;
        
        // test createGearOrderDemographics
        String childAlias = 'Test Child';
        String childGender = 'Unknown';
        String childAge = 'Unknown';
        String childRaceEthnicity = 'Other/Unknown';
        String parentGender = 'Unknown';
        String parentAge = 'Unknown';
        String parentRaceEthnicity = 'Other/Unknown';
        String parentMaritalStatus = 'Unknown';
        String comment = 'test comment';
        
        Gear_Order_Demographic__c demographic = GearOrderDemographicsController.createGearOrderDemographic(orderID, childAlias, 
            childGender, childAge, childRaceEthnicity, 
        	parentGender, parentAge, parentRaceEthnicity, parentMaritalStatus, 
            comment);
        
        // update
        childGender = 'Female';
        childAge = 'Unknown';
        childRaceEthnicity = 'African';
        String demographicID = demographic.Id;
        
        demographic = GearOrderDemographicsController.updateGearOrderDemographic(orderID, demographicID, childAlias, 
            childGender, childAge, childRaceEthnicity, 
        	parentGender, parentAge, parentRaceEthnicity, parentMaritalStatus, 
            comment);  
		System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderDemographics - updated: ' + demographic);
        
		// test getGearOrderDemographics
        List<Gear_Order_Demographic__c> demographicsList = GearOrderDemographicsController.getGearOrderDemographics(orderID);   
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderDemographics - demographicsList: ' + demographicsList);
        System.assert(demographicsList.size() == 1);
        demographic = demographicsList.get(0);
        System.assert(demographic.Child_Age__c == 'Unknown');
        
        // delete
        demographic = GearOrderDemographicsController.deleteGearOrderDemographic(orderID, demographic.Id);  
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderDemographics - deleted: ' + demographic);
        
        demographicsList = GearOrderDemographicsController.getGearOrderDemographics(orderID);  
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderDemographics - retrieved again: ' + demographicsList);
		System.assert(demographicsList.size() == 0);
        
    } // end test_crudGearOrderDemographics
    
    @isTest static void test_updateNumFamiliesServed() {
        
        System.debug('GearOrderDemographicsController_Test >> test_updateNumFamiliesServed > start');
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;

		// update
		Integer numFamiliesServed = 100;
		String response = GearOrderDemographicsController.updateNumFamiliesServed(order.Id, numFamiliesServed);        
        System.debug('GearOrderDemographicsController_Test >> test_updateNumFamiliesServed > response: ' + response);
        
    } // end test_updateNumFamiliesServed        
    
    @isTest static void test_updateDemographics() { 
        
        System.debug('GearOrderDemographicsController_Test >> test_updateDemographics > start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;

        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;  
        String orderID = order.Id;
        
        // test createGearOrderDemographics
        String childAlias = 'Test Child';
        String childGender = 'Unknown';
        String childAge = 'Unknown';
        String childRaceEthnicity = 'Other/Unknown';
        String parentGender = 'Unknown';
        String parentAge = 'Unknown';
        String parentRaceEthnicity = 'Other/Unknown';
        String parentMaritalStatus = 'Unknown';
        String comment = 'test comment';
        
        Gear_Order_Demographic__c demographic = GearOrderDemographicsController.createGearOrderDemographic(orderID, childAlias, 
            childGender, childAge, childRaceEthnicity, 
        	parentGender, parentAge, parentRaceEthnicity, parentMaritalStatus, 
            comment);

        // test updateDemographics
        List<Gear_Order_Demographic__c> demographicsList = [SELECT Id, Name FROM Gear_Order_Demographic__c WHERE Gear_Order__c = :orderID];        
        demographic = demographicsList.get(0);        
		String demographicList = '[{"ChildAlias":"Bob","Name":"' + demographic.Name + '"}]'; // json string representing datatable inline edits
        System.debug('GearOrderDemographicsController_Test >> test_updateDemographics > demographicList: ' + demographicList);
        List<String> responseList = GearOrderDemographicsController.updateDemographics(orderID, demographicList);    
                
    } // end test_createGearOrderDemographics      

    @isTest static void test_crudGearOrderSiblingDemographics() { 
        
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderSiblingDemographics > start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;

        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;  
        String orderID = order.Id;
        
        // create demographic
        String childAlias = 'Test Child';
        String childGender = 'Unknown';
        String childAge = 'Unknown';
        String childRaceEthnicity = 'Other/Unknown';
        String parentGender = 'Unknown';
        String parentAge = 'Unknown';
        String parentRaceEthnicity = 'Other/Unknown';
        String parentMaritalStatus = 'Unknown';
        String comment = 'test comment';
        
        Gear_Order_Demographic__c demographic = GearOrderDemographicsController.createGearOrderDemographic(orderID, childAlias, 
            childGender, childAge, childRaceEthnicity, 
        	parentGender, parentAge, parentRaceEthnicity, parentMaritalStatus, 
            comment);

        List<Gear_Order_Demographic__c> demographicsList = [SELECT Id, Name FROM Gear_Order_Demographic__c WHERE Gear_Order__c = :orderID];        
        demographic = demographicsList.get(0);
        String demographicID = demographic.Id;
        
		// test createGearOrderSiblingDemographic
        String siblingGender = 'Unknown';
        String siblingAge = 'Unknown';
        
        Gear_Order_Sibling_Demographic__c sibling = GearOrderDemographicsController.createGearOrderSiblingDemographic(demographicID, siblingGender, siblingAge);

        // test get sibling
        List<Gear_Order_Sibling_Demographic__c> siblingsList = GearOrderDemographicsController.getGearOrderSiblingDemographics(demographicID);
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderSiblingDemographics - siblingsList: ' + siblingsList);        
		System.assert(siblingsList.size() == 1);
        sibling = siblingsList.get(0);
        String siblingDemographicID = sibling.Id;
        
        // test updateGearOrderSiblingDemographic
        siblingGender = 'Female';
        siblingAge = 'Unknown';
        
        sibling = GearOrderDemographicsController.updateGearOrderSiblingDemographic(siblingDemographicID, siblingGender, siblingAge);
		System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderSiblingDemographics - updated: ' + sibling);
        
        // test deleteGearOrderSiblingDemographic
        sibling = GearOrderDemographicsController.deleteGearOrderSiblingDemographic(siblingDemographicID);
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderSiblingDemographics - deleted: ' + sibling);
        
        siblingsList = GearOrderDemographicsController.getGearOrderSiblingDemographics(demographicID);
        System.debug('GearOrderDemographicsController_Test >> test_crudGearOrderSiblingDemographics - retrieved again: ' + siblingsList);
		System.assert(siblingsList.size() == 0);
                       
    } // end test_crudGearOrderSiblingDemographics      
     
} // end GearOrderDemographicsController_Test