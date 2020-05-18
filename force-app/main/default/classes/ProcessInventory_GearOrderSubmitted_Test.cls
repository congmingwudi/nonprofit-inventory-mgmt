@isTest
private class ProcessInventory_GearOrderSubmitted_Test {

    @isTest static void test_submitGearOrderItems() {
        
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
        
        System.debug('test_submitGearOrderItems > inserting lineItems: ' + lineItems);
        insert lineItems;
        
        // --- test

        List<Gear_Order__c> orders = new List<Gear_Order__c>();
        orders.add(order);
        System.debug('test_submitGearOrderItems > orders: ' + orders);
        
        ProcessInventory_GearOrderSubmitted.submitGearOrderItems(orders);
        
        List<Product__c> productList = [SELECT Quantity_Needed__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantityNeeded = productList.get(0).Quantity_Needed__c;
        
        Decimal expectedQuantityNeeded = (lineItemQuantity * lineItems.size());
        
        System.debug('test_submitGearOrderItems > expected quantity needed: ' + expectedQuantityNeeded + ', actual quantity needed: ' + actualQuantityNeeded);
        System.assertEquals(expectedQuantityNeeded, actualQuantityNeeded, 'product quantity needed was not updated correctly');

    } // end test_submitGearOrderItems
    
    @isTest static void test_submitGearOrderBundleItems() {
        
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
        Decimal productQuantity = 30;
        Product__c product = new Product__c(Name='TestProduct',
                                           	Item_Bundle__c=productItemBundle,
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

        // order line items
        Decimal lineItemQuantity = 1;
        List<Gear_Order_Item__c> lineItems = new List<Gear_Order_Item__c>();
        Gear_Order_Item__c lineItem = null;

        	// gender = neutral
        lineItem = new Gear_Order_Item__c(Gear_Order__c=order.Id, Gear_Order_Demographic__c = demographic.Id,
                                          Product__c=product.Id, Quantity__c=lineItemQuantity, Fulfilled__c=true, 
                                          Gender__c='Neutral'); 
        lineItems.add(lineItem);
        
        System.debug('test_submitGearOrderBundleItems > inserting lineItems: ' + lineItems);
        insert lineItems;
        
        // --- test

        List<Gear_Order__c> orders = new List<Gear_Order__c>();
        orders.add(order);
        System.debug('test_submitGearOrderBundleItems > orders: ' + orders);
        
        ProcessInventory_GearOrderSubmitted.submitGearOrderItems(orders);
        
        List<Product__c> productList = [SELECT Quantity_Needed__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantityNeeded = productList.get(0).Quantity_Needed__c;
        
        Decimal expectedQuantityNeeded = (lineItemQuantity * productItemBundle) * lineItems.size();
        
        System.debug('test_submitGearOrderBundleItems > expected quantity needed: ' + expectedQuantityNeeded + ', actual quantity needed: ' + actualQuantityNeeded);
        System.assertEquals(expectedQuantityNeeded, actualQuantityNeeded, 'product quantity needed was not updated correctly');

    } // end test_submitGearOrderBundleItems    
    
    
}