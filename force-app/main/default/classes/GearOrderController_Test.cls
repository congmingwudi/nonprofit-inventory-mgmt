@isTest
private class GearOrderController_Test {
    
    @isTest static void test_getPartnerOrgSelection() {
        
        System.debug('GearOrderController_Test >> test_getGearOrder > start');
    	List<Account> partnerOrgList = GearOrderController.getPartnerOrgSelection();
        System.debug('GearOrderController_Test >> test_getGearOrder > partnerOrgList: ' + partnerOrgList);
    }
    
    @isTest static void test_getGearOrderDemographicSelection() {
        
        System.debug('GearOrderController_Test >> test_getGearOrderDemographicSelection > start');
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order; 
        
        List<Gear_Order_Demographic__c> demographicList = GearOrderController.getGearOrderDemographicSelection(order.Id);

    }

    @isTest static void test_demographicsServed() {

        Test.startTest();

        // test 1
        System.debug('GearOrderController_Test > test_demographicsServed - start test');

        Account partner = new Account();
        partner.Name = 'Test Account';
        insert partner;

        Integer numFamiliesServed = 20;
        String demographicList = '[{"RaceEthnicity":"African","PercentFamiliesServed":"50"},{"RaceEthnicity":"African American","PercentFamiliesServed":"50"}]';
        List<String> results = PartnerSignupController.createDemographicsServed(partner.Id, numFamiliesServed, demographicList);

        GearOrderController.DemographicsServedDetails details = GearOrderController.getDemographicsServed(partner.Id);
        System.debug('GearOrderController_Test > test_demographicsServed - details: ' + details);

        System.debug('GearOrderController_Test > test_demographicsServed - end test');

        Test.stopTest();

    } // end test_demographicsServed
    
    @isTest static void test_getGearOrder() {
        
        System.debug('GearOrderController_Test >> test_getGearOrder > start');
        
        List<Gear_Order__c> orders = null;
        
        // *** test GearOrderController.getGearOrder
        
        // test w/ orderID
        String orderID = '1';
        String orderName = null;
        orders = GearOrderController.getGearOrder(orderID, orderName);
        System.debug('GearOrderController_Test >> test_getGearOrder - orders 1: ' + orders);
                
        // test w/ orderName
        orderID = null;
        orderName = '1';
        orders = GearOrderController.getGearOrder(orderID, orderName); 
        System.debug('GearOrderController_Test >> test_getGearOrder - orders 2: ' + orders);

        // *** test GearOrderController.getGearOrderForBulkDemographics
        
        // test w/ orderID
        orderID = '1';
        orderName = null;
        orders = GearOrderController.getGearOrderForBulkDemographics(orderID, orderName);
        System.debug('GearOrderController_Test >> test_getGearOrder (ForBulkDemographics) - orders 3: ' + orders);
                
        // test w/ orderName
        orderID = null;
        orderName = '1';
        orders = GearOrderController.getGearOrderForBulkDemographics(orderID, orderName); 
        System.debug('GearOrderController_Test >> test_getGearOrder (ForBulkDemographics) - orders 4: ' + orders);


        
    } // end test_getGearOrder 
    
    @isTest static void test_getProductSelection() {
        
        System.debug('GearOrderController_Test >> test_getProductSelection > start');
        List<Product__c> productList = GearOrderController.getProductSelection();
        System.debug('GearOrderController_Test >> productSelection: ' + productList.size());
        
    } // end test_getProductSelection
    
    @isTest static void test_crudGearOrderItem() {
        
        System.debug('GearOrderController_Test >> test_crudGearOrderItem > start');
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;                
        
        // product
        Product__c product = new Product__c(Name='TestProduct',
                                            Value__c=1,Weight__c=1
                                           ); 
        insert product;
        
        // orderItem
        String orderID = order.Id;
        String demographicID = null;
        String productID = product.Id;
        Integer quantity = 1;
        String season = null; 
        String clothingSize = null;
        String diaperSize = null;
        String comment = null;
        Gear_Order_Item__c orderItem = GearOrderController.createGearOrderItem(orderID, demographicID, productID, quantity, season, clothingSize, diaperSize, comment);               
        System.debug('GearOrderController_Test >> test_crudGearOrderItem - created: ' + orderItem);
        
        // update
        quantity = 5;
        orderItem = GearOrderController.updateGearOrderItem(orderID, orderItem.Id, productID, quantity, season, clothingSize, diaperSize, comment);  
		System.debug('GearOrderController_Test >> test_crudGearOrderItem - updated: ' + orderItem);
        
        // update order comment
        comment = 'test comment for order';
        String response = GearOrderController.updateOrderComment(orderID, comment);
        System.debug('GearOrderController_Test >> test_crudGearOrderItem - order comment updated: ' + response);

        // update preferred pickup times - no times work
        Boolean noTimesWork = true;
        String noTimesWorkComment = 'some comment about times that work';
        String pickupTimezone = 'America/Denver';
        String pickupDateTime1String = null; 
        String pickupDateTime2String = null; 
        response = GearOrderController.updatePreferredPickupTimes(orderID, noTimesWork, noTimesWorkComment, pickupTimezone, pickupDateTime1String, pickupDateTime2String);
        System.debug('GearOrderController_Test >> test_crudGearOrderItem - order preferred pickup times updated: ' + response);

        // update preferred pickup times
        noTimesWork = false;
        noTimesWorkComment = null;
        pickupDateTime1String = '11/10/2018 9:00 AM';
        pickupDateTime2String = '11/17/2018 9:00 AM';
        response = GearOrderController.updatePreferredPickupTimes(orderID, noTimesWork, noTimesWorkComment, pickupTimezone, pickupDateTime1String, pickupDateTime2String);
        System.debug('GearOrderController_Test >> test_crudGearOrderItem - order preferred pickup times updated: ' + response);
        
		// retrieve 
        List<Gear_Order_Item__c> orderItemList = GearOrderController.getGearOrderItems(orderID);  
		System.debug('GearOrderController_Test >> test_crudGearOrderItem - retrieved: ' + orderItem);
                
        // delete
        orderItem = GearOrderController.deleteGearOrderItem(orderID, orderItem.Id);  
        System.debug('GearOrderController_Test >> test_crudGearOrderItem - deleted: ' + orderItem);
        
        orderItemList = GearOrderController.getGearOrderItems(orderID);  
        System.debug('GearOrderController_Test >> test_crudGearOrderItem - retrieved again: ' + orderItemList);
		System.assert(orderItemList.size() == 0);
        
    } // end test_crudGearOrderItem 
    
    @isTest static void test_Dates() {
        
        String dateTimeString = '11/15/2018 9:00 AM'; // this will be stored as GMT when coming from unauthenticated user
        String targetTimezone = 'America/Denver';
            
        DateTime theDateTime = GearOrderController.getTimezoneAdjustedDate(targetTimeZone, dateTimeString);
        System.debug('GearOrderController_Test >> test_Dates - theDateTime (GMT for time adjusted for Denver): ' + theDateTime);   
        
        targetTimezone = 'America/Chicago';
        theDateTime = GearOrderController.getTimezoneAdjustedDate(targetTimeZone, dateTimeString);
        System.debug('GearOrderController_Test >> test_Dates - theDateTime (GMT for time adjusted for Chicago): ' + theDateTime);   


    } // end test_Dates

    @isTest(SeeAllData=true) static void test_getNextPickupDatesAvailable() {
        // TODO: create test Event records instead of using SeeAllData

        System.debug('GearOrderController_Test >> test_getNextPickupDatesAvailable - user: ' + UserInfo.getUserName());

        Integer numDates = 3;

        List<String> nextDates = GearOrderController.getNextPickupDatesAvailable(numDates);
        System.debug('GearOrderController_Test >> test_getNextPickupDatesAvailable - nextDates: ' + nextDates);

    } // end test_getNextPickupDatesAvailable

    @isTest static void test_getPicklistValues() { 
        
        System.debug('GearOrderController_Test >> test_getPicklistValues > start');
        
        SObject obj = new Gear_Order_Item__c();
        String field = 'Gender__c';
        List<GearOrderController.Option> options = GearOrderController.getPicklistValues(obj, field); 
        //List<String> options = GearOrderController.getPicklistValues(obj, field); 
        System.debug('GearOrderController_Test >> test_getPicklistValues > options: ' + options);
        
    } // end test_getPicklistValues     

    @isTest static void test_createGearOrderDemographics() { 
        
        System.debug('GearOrderController_Test >> test_createGearOrderDemographics > start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;

        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;  
        
        // test createGearOrderDemographics
        Integer totalNumFamiliesServed = 20;
        String demographicList = '[{"RaceEthnicity":"African","PercentFamiliesServed":"50","NumFamiliesServed":10},{"RaceEthnicity":"African American","PercentFamiliesServed":"50","NumFamiliesServed":10},{"RaceEthnicity":"Asian","PercentFamiliesServed":0,"NumFamiliesServed":0},{"RaceEthnicity":"Caucasian","PercentFamiliesServed":0,"NumFamiliesServed":0},{"RaceEthnicity":"Hispanic","PercentFamiliesServed":0,"NumFamiliesServed":0},{"RaceEthnicity":"Native American","PercentFamiliesServed":0,"NumFamiliesServed":0},{"RaceEthnicity":"Other/Unknown","PercentFamiliesServed":0,"NumFamiliesServed":0}]';        
        List<String> responseList = GearOrderController.createGearOrderDemographics(order.Id, totalNumFamiliesServed, demographicList);
        
        // check if Gear Order 
        List<Gear_Order__c> orders = [SELECT Num_Families_Served__c FROM Gear_Order__c WHERE Id = :order.Id];
        Gear_Order__c updatedOrder = orders.get(0);
        System.debug('GearOrderController_Test >> test_createGearOrderDemographics - updated totalNumFamiliesServed: ' + updatedOrder.Num_Families_Served__c);
        System.assert(updatedOrder.Num_Families_Served__c == totalNumFamiliesServed);
        
        // check if the correct # of demographics were created. 
        List<Gear_Order_Demographic__c> newDemographicsList = [SELECT Child_Race_Ethnicity__c FROM Gear_Order_Demographic__c WHERE Gear_Order__c = :order.Id];
        System.debug('GearOrderController_Test >> test_createGearOrderDemographics - demographics created: ' + newDemographicsList.size());
        System.assert(newDemographicsList.size() == totalNumFamiliesServed);
        
        Integer numAfrican = 0;
        Integer numAfricanAmerican = 0;
        for (Integer i = 0; i < newDemographicsList.size(); ++i) {
            Gear_Order_Demographic__c d = newDemographicsList.get(i);
            if (d.Child_Race_Ethnicity__c == 'African') { numAfrican++; }
            else if (d.Child_Race_Ethnicity__c == 'African American') { numAfricanAmerican++; }
        }
        System.assert(numAfrican == 10);
        System.assert(numAfricanAmerican == 10);
                
    } // end test_createGearOrderDemographics         
     
} // end GearOrderController_Test