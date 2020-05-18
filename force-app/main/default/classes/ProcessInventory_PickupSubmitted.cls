global without sharing class ProcessInventory_PickupSubmitted {
   
    @InvocableMethod(label='Inventory In Pickup Items')
    global static void submitPickupItems(List<Pickup__c> pickups) {
		
        if (pickups != null) {
            
            // pickupIds
            List<Id> pickupIds = new List<Id>();
            for(Pickup__c pickup : pickups) { pickupIds.add(pickup.Id); }
            
            // pickup map w/ list of pickup line items
            Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>(
            	[SELECT Id, (SELECT Id, Name, Product__c, Quantity__c FROM Pickup_Items__r) FROM Pickup__c WHERE Id IN :pickupIds]);
            
            // product map
            Map<Id, Product__c> productMap = new Map<Id, Product__c>(
            	[SELECT Id, Name, Quantity__c FROM Product__c]);

            // products to update map (using map because it's possible to have multiple pickup line items for the same product but different gender)
           	Map<Id, Product__c> productsToUpdateMap = new Map<Id, Product__c>();
            
            for(Pickup__c pickup : pickups) {
                System.debug('ProcessInventory_PickupSubmitted - pickup: ' + pickup.Name);
                
                // get pickup line items as children of the pickup
                List<Pickup_Line_Item__c> lineItems = pickupMap.get(pickup.Id).Pickup_Items__r;
                                
                // calculate new product quantity (in stock) based on pickup line item quantity submitted                
                for(Pickup_Line_Item__c lineItem : lineItems) {                    
                    System.debug('ProcessInventory_PickupSubmitted - pickup - lineItem: ' + lineItem);

                    // get product for this pickup line item. use product in productsToUpdateMap if it exists
                    Product__c product = null;
                    if (productsToUpdateMap.containsKey(lineItem.Product__c)) {
                        product = productsToUpdateMap.get(lineItem.Product__c);
                    } else {
                        product = productMap.get(lineItem.Product__c);
                    }                    
                    System.debug('ProcessInventory_PickupSubmitted - pickup - lineItem product: ' + product);                

                    // increment product quantity (in stock) by the quantity submitted with this pickup line item
                    Decimal newQuantity = product.Quantity__c + lineItem.Quantity__c;
                    System.debug('ProcessInventory_PickupSubmitted - newQuantity for \"' + product.Name + '\": ' + newQuantity);
                	product.Quantity__c = newQuantity;
                    
                    /*
                    // increment product gender quantity from pickup line item                    
                    if(lineItem.Gender__c == 'Neutral') {
                        if (product.Gender_Neutral__c == null) { product.Gender_Neutral__c = 0; }
                        product.Gender_Neutral__c += lineItem.Quantity__c;
                        System.debug('ProcessInventory_PickupSubmitted - new gender neutral for \"' + product.Name + '\": ' + product.Gender_Neutral__c);
                    } else if(lineItem.Gender__c == 'Male') {
                        if (product.Gender_Male__c == null) { product.Gender_Male__c = 0; }
                        product.Gender_Male__c += lineItem.Quantity__c;
                        System.debug('ProcessInventory_PickupSubmitted - new gender male for \"' + product.Name + '\": ' + product.Gender_Male__c);
                    } else if(lineItem.Gender__c == 'Female') {
                        if (product.Gender_Female__c == null) { product.Gender_Female__c = 0; }
                        product.Gender_Female__c += lineItem.Quantity__c;
                        System.debug('ProcessInventory_PickupSubmitted - new gender female for \"' + product.Name + '\": ' + product.Gender_Female__c);
                    }                   
					*/
                    
                   	productsToUpdateMap.put(product.Id, product);
                } // end for line items           	
            } // end for pickups
            
            // update product quantities
            List<Product__c> productsToUpdate = productsToUpdateMap.values();
            update productsToUpdate;
            System.debug('ProcessInventory_PickupSubmitted - product quantities updated: ' + productsToUpdate.size());
            
        } // end if pickups
        
    } // end submitPickupItems
    
} // end ProcessInventory_PickupSubmitted