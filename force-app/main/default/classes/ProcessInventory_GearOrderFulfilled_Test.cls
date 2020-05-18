@isTest
private class ProcessInventory_GearOrderFulfilled_Test {

    @isTest static void test_fulfillGearOrderItems() {
        
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
        Decimal productQuantityNeeded = 5;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Quantity__c=productQuantity,
                                           	Quantity_Needed__c=productQuantityNeeded,
                                            Value__c=1,Weight__c=1
                                           ); 
        insert product;
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
        demographic.Child_Age__c = 'Unknown';
        demographic.Child_Gender__c = 'Male';
        demographic.Gear_Order__c = order.Id;
        insert demographic; 

        // order line items
        Decimal lineItemQuantity = 1;
        List<Gear_Order_Item__c> lineItems = new List<Gear_Order_Item__c>();
        Gear_Order_Item__c lineItem = null;

        	// gender = neutral
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id, 
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Neutral'); 
        lineItems.add(lineItem);
        
        	// gender = male
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Male'); 
        lineItems.add(lineItem);  
        
        	// gender = female
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Female'); 
        lineItems.add(lineItem);
        
        System.debug('test_fulfillGearOrderItems > inserting lineItems: ' + lineItems);
        insert lineItems;
                
        // --- test
        List<Gear_Order__c> orders = new List<Gear_Order__c>();
        orders.add(order);
        System.debug('test_fulfillGearOrderItems > orders: ' + orders);
        
        //TODO: turn back on after deployment
        /*
        ProcessInventory_GearOrderFulfilled.fulfillGearOrderItems(orders);
        
        List<Product__c> productList = [SELECT Quantity__c, Quantity_Needed__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantity = productList.get(0).Quantity__c;
        Decimal actualQuantityNeeded = productList.get(0).Quantity_Needed__c;
        
        Decimal expectedQuantity = productQuantity - (lineItemQuantity * lineItems.size());
        System.debug('test_fulfillGearOrderItems > expected quantity: ' + expectedQuantity + ', actual quantity: ' + actualQuantity);
        System.assertEquals(expectedQuantity, actualQuantity, 'product quantity was not updated correctly');
        
        Decimal expectedQuantityNeeded = productQuantityNeeded - (lineItemQuantity * lineItems.size());
        System.debug('test_fulfillGearOrderItems > test_fulfillGearOrderItems > expected quantity needed: ' + expectedQuantityNeeded + ', actual quantity needed: ' + actualQuantityNeeded);
        System.assertEquals(expectedQuantityNeeded, actualQuantityNeeded, 'product quantity needed was not updated correctly');
        */
        
    } // end test_fulfillGearOrderItems
    
    @isTest static void test_fulfillShortGearOrderItems() {
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;                
        
        // product
        Decimal productQuantity = 10;
        Decimal productQuantityNeeded = 10;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Quantity__c=productQuantity,
                                           	Quantity_Needed__c=productQuantityNeeded,
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
        Decimal lineItemQuantity = 10;
        Gear_Order_Item__c lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id,
                                                              Gear_Order_Demographic__c = demographic.Id,
                                                              Product__c=product.Id,
                                                              Quantity__c=lineItemQuantity,
                                                              Fulfilled__c=true);                             
        insert lineItem;
        
        // update order line item to set a short quantity fulfilled
        Decimal lineItemQuantityFulfilled = 5; 
        lineItem.Quantity_Fulfilled__c = lineItemQuantityFulfilled;
        update lineItem;
        
        // --- test
        List<Gear_Order__c> orders = new List<Gear_Order__c>();
        orders.add(order);
        System.debug('test_fulfillShortGearOrderItems > orders: ' + orders);
        System.debug('test_fulfillShortGearOrderItems > lineItem: ' + lineItem);
        
        ProcessInventory_GearOrderFulfilled.fulfillGearOrderItems(orders);
        
        List<Product__c> productList = [SELECT Quantity__c, Quantity_Needed__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantity = productList.get(0).Quantity__c;
        Decimal actualQuantityNeeded = productList.get(0).Quantity_Needed__c;
        
        Decimal expectedQuantity = productQuantity - lineItemQuantityFulfilled;
        System.debug('test_fulfillShortGearOrderItems > expected quantity: ' + expectedQuantity + ', actual quantity: ' + actualQuantity);
        System.assertEquals(expectedQuantity, actualQuantity, 'product quantity was not updated correctly');
        
        Decimal expectedQuantityNeeded = productQuantityNeeded - lineItemQuantity;
        System.debug('test_fulfillShortGearOrderItems > expected quantity needed: ' + expectedQuantityNeeded + ', actual quantity needed: ' + actualQuantityNeeded);
        System.assertEquals(expectedQuantityNeeded, actualQuantityNeeded, 'product quantity needed was not updated correctly');

    } // end test_fulfillShortGearOrderItems
    
    @isTest static void test_fulfillGearOrderBundleItems() {
        
        // --- test data setup
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;                
        
        // product
        Decimal productItemBundle = 30;
        Decimal productQuantity = 90;
        Decimal productQuantityNeeded = 90;
        Product__c product = new Product__c(Name='TestProduct',
                                            Item_Bundle__c=productItemBundle,
                                           	Quantity__c=productQuantity,
                                           	Quantity_Needed__c=productQuantityNeeded,
                                            Value__c=1,Weight__c=1
                                           );
        insert product;
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
        demographic.Child_Age__c = 'Unknown';
        demographic.Child_Gender__c = 'Male';
        demographic.Gear_Order__c = order.Id;
        insert demographic; 

        // order line items
        Decimal lineItemQuantity = 1;
        List<Gear_Order_Item__c> lineItems = new List<Gear_Order_Item__c>();
        Gear_Order_Item__c lineItem = null;

        	// gender = neutral
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Neutral'); 
        lineItems.add(lineItem);
        
        	// gender = male
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Male'); 
        lineItems.add(lineItem);  
        
        	// gender = female
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Female'); 
        lineItems.add(lineItem);
        
        System.debug('test_fulfillGearOrderBundleItems > inserting lineItems: ' + lineItems);
        insert lineItems;
                
        // --- test
        List<Gear_Order__c> orders = new List<Gear_Order__c>();
        orders.add(order);
        System.debug('test_fulfillGearOrderBundleItems > orders: ' + orders);
        
        //TODO: turn back on after deployment
        /*
        Test.startTest();        
        
        ProcessInventory_GearOrderFulfilled.fulfillGearOrderItems(orders);
        
        List<Product__c> productList = [SELECT Quantity__c, Quantity_Needed__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantity = productList.get(0).Quantity__c;
        Decimal actualQuantityNeeded = productList.get(0).Quantity_Needed__c;
        
        Decimal expectedQuantity = productQuantity - (lineItemQuantity * productItemBundle * lineItems.size());
        System.debug('test_fulfillGearOrderBundleItems > expected quantity: ' + expectedQuantity + ', actual quantity: ' + actualQuantity);
        System.assertEquals(expectedQuantity, actualQuantity, 'product quantity was not updated correctly');
        
        Decimal expectedQuantityNeeded = productQuantityNeeded - (lineItemQuantity * productItemBundle * lineItems.size());
        System.debug('test_fulfillGearOrderBundleItems > expected quantity needed: ' + expectedQuantityNeeded + ', actual quantity needed: ' + actualQuantityNeeded);
        System.assertEquals(expectedQuantityNeeded, actualQuantityNeeded, 'product quantity needed was not updated correctly');
        
        Test.stopTest();
		*/
        
    } // end test_fulfillGearOrderBundleItems

    @isTest static void test_unfulfillGearOrderItems() {
        
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
        Decimal productQuantityNeeded = 5;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Quantity__c=productQuantity,
                                           	Quantity_Needed__c=productQuantityNeeded,
                                            Value__c=1,Weight__c=1
                                           ); 
        insert product;
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
        demographic.Child_Age__c = 'Unknown';
        demographic.Child_Gender__c = 'Male';
        demographic.Gear_Order__c = order.Id;
        insert demographic; 

        // order line items
        Decimal lineItemQuantity = 1;
        List<Gear_Order_Item__c> lineItems = new List<Gear_Order_Item__c>();
        Gear_Order_Item__c lineItem = null;

        	// gender = neutral
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id, 
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Neutral'); 
        lineItems.add(lineItem);
        
        	// gender = male
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Male'); 
        lineItems.add(lineItem);  
        
        	// gender = female
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Female'); 
        lineItems.add(lineItem);
        
        System.debug('test_unfulfillGearOrderItems > inserting lineItems: ' + lineItems);
        insert lineItems;
                
        // --- test
        List<Gear_Order__c> orders = new List<Gear_Order__c>();
        orders.add(order);
        System.debug('test_unfulfillGearOrderItems > orders: ' + orders);
        
        ProcessInventory_GearOrderUnFulfilled.unfulfillGearOrderItems(orders);
        
        List<Product__c> productList = [SELECT Quantity__c, Quantity_Needed__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantity = productList.get(0).Quantity__c;
        Decimal actualQuantityNeeded = productList.get(0).Quantity_Needed__c;
        
        Decimal expectedQuantity = productQuantity;
        System.debug('test_unfulfillGearOrderItems > expected quantity: ' + expectedQuantity + ', actual quantity: ' + actualQuantity);
        System.assertEquals(expectedQuantity, actualQuantity, 'product quantity was not updated correctly');
        
        Decimal expectedQuantityNeeded = productQuantityNeeded - (lineItemQuantity * lineItems.size());
        System.debug('test_unfulfillGearOrderItems > expected quantity needed: ' + expectedQuantityNeeded + ', actual quantity needed: ' + actualQuantityNeeded);
        System.assertEquals(expectedQuantityNeeded, actualQuantityNeeded, 'product quantity needed was not updated correctly');
        
    } // end test_unfulfillGearOrderItems    
    
} // end ProcessInventory_GearOrderFulfilled_Test