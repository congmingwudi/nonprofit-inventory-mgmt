@isTest
private class GearOrderTrigger_Test {
    
    @isTest static void test_submitted_success() {
        
        System.debug('test_submitted_success >> start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;

        // order contact
        Contact orderContact = new Contact(FirstName = 'Ryan', LastName='Cox');
        insert orderContact;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                Order_Created__c = dateTime.now(), Order_Contact__c = orderContact.Id
        );
        insert order;
        
        // product
        Decimal productQuantity = 5;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Quantity__c=productQuantity,
                                            Value__c=1,Weight__c=1
                                           );
        insert product;
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
        demographic.Child_Age__c = 'Unknown';
        demographic.Child_Gender__c = 'Male';
        demographic.Gear_Order__c = order.Id;
        insert demographic;        

        // order line item
        Decimal quantity = 2;
        Gear_Order_Item__c lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, 
                                                             Gear_Order_Demographic__c = demographic.Id,
                                                             Product__c=product.Id, 
                                                             Quantity__c=quantity
                                                           );
        insert lineItem;
                
        // --- test
        
        // set status
        order.Order_Status__c = 'Submitted';
        
        Test.startTest();
        Database.SaveResult result = Database.update(order);
        Test.stopTest();
        
        // verify status was changed
        System.debug('test_submitted_success >> result: ' + result);
        System.assert(result.isSuccess());
        
    } // end test_submitted_success

    
    @isTest static void test_submitted_error() {
        
        System.debug('test_submitted_error >> start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;                
        
        // no order line item will cause the trigger to throw an error when order status is set to "Submitted"
        
        // --- test
        
        // set status
        order.Order_Status__c = 'Submitted';
        
        Test.startTest();
        Database.SaveResult result = null;
        try {
        	result = Database.update(order);
    	} catch (Exception e) {
            System.debug('test_submitted_error >> exception: ' + e);
        }
        Test.stopTest();
        
        // verify status was changed
        System.debug('test_submitted_error >> result: ' + result);
        //if (result != null) {
        	//System.assert(!result.isSuccess());
        //}
        
    } // end test_submitted_error

    @isTest static void test_fulfilled_success() {
        
        System.debug('test_fulfilled_success >> start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;                
        
        // product
        Decimal productQuantity = 5;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Quantity__c=productQuantity,
                                            Value__c=1,Weight__c=1
                                           );
        insert product;
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
        demographic.Child_Age__c = 'Unknown';
        demographic.Child_Gender__c = 'Male';
        demographic.Gear_Order__c = order.Id;
        insert demographic;   

        // order line item (Fulfilled__c is true and the trigger allows the status update)
        Decimal quantity = 2;
        Gear_Order_Item__c lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id,
                                                              Gear_Order_Demographic__c = demographic.Id,
                                                              Product__c=product.Id,
                                                              Quantity__c=quantity,
                                                              Fulfilled__c=true);                             
        insert lineItem;
        
        // --- test
        
        // set status
        order.Order_Status__c = 'Fulfilled';
        
        Test.startTest();
        Database.SaveResult result = Database.update(order);
        Test.stopTest();
        
        // verify status was changed
        System.debug('test_fulfilled_success >> result: ' + result);
        System.assert(result.isSuccess());
        
    } // end test_fulfilled_success

    
    @isTest static void test_fulfilled_error() {
        
        System.debug('test_fulfilled_error >> start');
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;                
        
        // product
        Decimal productQuantity = 5;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Quantity__c=productQuantity,
                                            Value__c=1,Weight__c=1
                                           );
        insert product;
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
        demographic.Child_Age__c = 'Unknown';
        demographic.Child_Gender__c = 'Male';
        demographic.Gear_Order__c = order.Id;
        insert demographic; 

        // order line item (Fulfilled__c is false and causes the trigger to throw an error)
        Decimal quantity = 2;
        Gear_Order_Item__c lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id,
                                                              Gear_Order_Demographic__c = demographic.Id,
                                                              Product__c=product.Id,
                                                              Quantity__c=quantity);                             
        insert lineItem;
        
        // set order line item as not fulfilled
        lineItem.Fulfilled__c = false;
        update lineItem;

        
        // --- test
        
        // set status
        order.Order_Status__c = 'Fulfilled';
        
        Test.startTest();
        Database.SaveResult result = null;
        try {
    		result = Database.update(order);
    	} catch (Exception e) {
            System.debug('test_submitted_error >> exception: ' + e);
        }
        Test.stopTest();
        
        // verify status was changed
        System.debug('test_fulfilled_error >> result: ' + result);
        //if (result != null) {
        	//System.assert(!result.isSuccess());
        //}
        
    } // end test_fulfilled_error
    
} // end GearOrderTrigger_Test