global without sharing class ProcessInventory_GearOrderSubmitted {

    @InvocableMethod(label='Inventory Out Pending Gear Order Items')    
    global static void submitGearOrderItems(List<Gear_Order__c> orders) {
		
        if (orders != null) {
            
       		// orderIds
            List<Id> orderIds = new List<Id>();
            for(Gear_Order__c order : orders) { orderIds.add(order.Id); }
            
            // order map w/ list of order line items
            Map<Id, Gear_Order__c> orderMap = new Map<Id, Gear_Order__c>(
            	[SELECT Id, (SELECT Id, Name, Product__c, Quantity__c FROM Gear_Order_Items__r) FROM Gear_Order__c WHERE Id IN :orderIds]);
            
            // product map
            Map<Id, Product__c> productMap = new Map<Id, Product__c>(
            	[SELECT Id, Name, Item_Bundle__c, Quantity_Needed__c FROM Product__c]);            

            // products to update map (using map because it's possible to have multiple lines items for the same product but different gender)
           	Map<Id, Product__c> productsToUpdateMap = new Map<Id, Product__c>();            
            
            for(Gear_Order__c order : orders) {
                System.debug('ProcessInventory_GearOrderSubmitted - order: ' + order.Id);
                
                // get order line items as children of the order
                List<Gear_Order_Item__c> lineItems = orderMap.get(order.Id).Gear_Order_Items__r;
                System.debug('ProcessInventory_GearOrderSubmitted - lineItems empty: ' + lineItems.isEmpty());
                
                if (!lineItems.isEmpty()) {
                    
                    // calculate new product quantity (in stock) based on order line item quantity submitted
                    for(Gear_Order_Item__c lineItem : lineItems) {                    
                        System.debug('ProcessInventory_GearOrderSubmitted - lineItem: ' + lineItem);
                    
                        // get product for this line item. use product in productsToUpdateMap if it exists
                        Product__c product = null;
                        if (productsToUpdateMap.containsKey(lineItem.Product__c)) {
                            product = productsToUpdateMap.get(lineItem.Product__c);
                        } else {
                            product = productMap.get(lineItem.Product__c);
                        }                    
                        System.debug('ProcessInventory_GearOrderSubmitted - lineItem product: ' + product);                
                    
                        // add product quantity needed by the quantity submitted with this order line item
						// take into account product item bundles 
						// (ex. if you order Clothing with quantity of 1, then you will get a bundle of 30 clothing items)
                        if (product.Item_Bundle__c == null) { product.Item_Bundle__c = 1; }
                        Decimal newQuantity = product.Quantity_Needed__c + (lineItem.Quantity__c * product.Item_Bundle__c);
                        System.debug('ProcessInventory_GearOrderSubmitted - new quantity needed for \"' + product.Name + '\": ' + newQuantity);
                        product.Quantity_Needed__c = newQuantity;
                        
                        System.debug('ProcessInventory_GearOrderSubmitted - new product quantities: ' + product);
                        productsToUpdateMap.put(product.Id, product);
                        
                    } // end for line items
                    
                } // end if line items
                
            } // end for orders
            
            // update product quantities
            List<Product__c> productsToUpdate = productsToUpdateMap.values();
            update productsToUpdate;
            System.debug('ProcessInventory_GearOrderSubmitted - product quantities updated: ' + productsToUpdate.size());
            
        } // end if orders
        
    } // end submitGearOrderItems   
    
} // end ProcessInventory_PickupSubmitted