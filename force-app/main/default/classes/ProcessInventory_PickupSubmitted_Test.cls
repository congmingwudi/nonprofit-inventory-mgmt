@isTest
private class ProcessInventory_PickupSubmitted_Test {

    @isTest static void test_submitPickupItems() {
        
        // --- test data setup
        
        // product
        Product__c product = new Product__c(Name='TestProduct', 
                                            Value__c=1,Weight__c=1
                                           );
        insert product;
        
        // donation location
        Donation_Location__c donationLocation = new Donation_Location__c(Name='TestDonationLocation');
        insert donationLocation;
        
        // user
        Id userId = UserInfo.getUserId();
        
        // pickup
        Pickup__c pickup = new Pickup__c(Name='TestPickup', 
                                         Donation_Location__c=donationLocation.Id,
                                         Pickup_Date__c=dateTime.now(),
                                         Gear_Coordinator__c=userId);
        insert pickup;
        
        // pickup line items
        Decimal lineItemQuantity = 5;
        List<Pickup_Line_Item__c> lineItems = new List<Pickup_Line_Item__c>();
        Pickup_Line_Item__c lineItem = null;
        
        	// line item 1
        lineItem = new Pickup_Line_Item__c(Pickup__c=pickup.Id, Product__c=product.Id, Quantity__c=lineItemQuantity);
        lineItems.add(lineItem);
        
        	// line item 2
        lineItem = new Pickup_Line_Item__c(Pickup__c=pickup.Id, Product__c=product.Id, Quantity__c=lineItemQuantity);
        lineItems.add(lineItem);
        
        	// line item 3
        lineItem = new Pickup_Line_Item__c(Pickup__c=pickup.Id, Product__c=product.Id, Quantity__c=lineItemQuantity);
        lineItems.add(lineItem);
        
        System.debug('test_submitPickupItems > inserting lineItems: ' + lineItems);
        insert lineItems;
        
        // --- test
        List<Pickup__c> pickups = new List<Pickup__c>();
        pickups.add(pickup);
        System.debug('test_submitPickupItems > pickups: ' + pickups);
        
        ProcessInventory_PickupSubmitted.submitPickupItems(pickups);
        
        List<Product__c> productList = [SELECT Quantity__c FROM Product__c WHERE Id = :product.Id];
        Decimal actualQuantity = productList.get(0).Quantity__c;
        //Decimal actualGenderNeutral = productList.get(0).Gender_Neutral__c;
        //Decimal actualGenderMale = productList.get(0).Gender_Male__c;
        //Decimal actualGenderFemale = productList.get(0).Gender_Female__c;
        
        // check quantity
        Decimal expectedQuantity = lineItemQuantity * lineItems.size();
        System.debug('test_submitPickupItems > expected quantity: ' + expectedQuantity + ', actual quantity: ' + actualQuantity);
        System.assertEquals(expectedQuantity, actualQuantity, 'product quantity was not updated correctly');
        
        /*
        // check gender quantity
        System.debug('test_submitPickupItems > expected gender Neutral: ' + lineItemQuantity + ', actual: ' + actualGenderNeutral);
        System.assertEquals(lineItemQuantity, actualGenderNeutral, 'product gender Neutral quantity was not updated correctly');
        System.debug('test_submitPickupItems > expected gender Male: ' + lineItemQuantity + ', actual: ' + actualGenderMale);
        System.assertEquals(lineItemQuantity, actualGenderMale, 'product gender Male quantity was not updated correctly');
        System.debug('test_submitPickupItems > expected gender Female: ' + lineItemQuantity + ', actual: ' + actualGenderFemale);
        System.assertEquals(lineItemQuantity, actualGenderFemale, 'product gender Female quantity was not updated correctly');
        */
        
    } // end test_submitPickupItems
    
}