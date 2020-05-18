global without sharing class ProcessInventory_GearOrderUnfulfilled {

    @InvocableMethod(label='Unfulfill Gear Order')    
    global static void unfulfillGearOrderItems(List<Gear_Order__c> orders) {
		
        if (orders != null) {

       		// orderIds
            List<Id> orderIds = new List<Id>();
            for(Gear_Order__c order : orders) { orderIds.add(order.Id); }
            
            // order map w/ list of order line items
            Map<Id, Gear_Order__c> orderMap = new Map<Id, Gear_Order__c>(
            	[SELECT Id, (SELECT Id, Name, Product__c, Quantity__c, Quantity_Fulfilled__c, Fulfilled__c FROM Gear_Order_Items__r) FROM Gear_Order__c WHERE Id IN :orderIds]);
            
            // product map
            Map<Id, Product__c> productMap = new Map<Id, Product__c>(
            	[SELECT Id, Name, Item_Bundle__c, Quantity__c, Quantity_Needed__c FROM Product__c]);          
            
            // products to update map (using map because it's possible to have multiple lines items for the same product but different gender)
           	Map<Id, Product__c> productsToUpdateMap = new Map<Id, Product__c>();
            
            // line items to update list
            List<Gear_Order_Item__c> orderItemsToUpdateList = new List<Gear_Order_Item__c>();
            
            for(Gear_Order__c order : orders) {
                System.debug('ProcessInventory_GearOrderFulfilled - order: ' + order.Id);
                
                // get order line items as children of the order
                List<Gear_Order_Item__c> lineItems = orderMap.get(order.Id).Gear_Order_Items__r;                
                System.debug('ProcessInventory_GearOrderUnfulfilled - lineItems empty: ' + lineItems.isEmpty());
                
                if (!lineItems.isEmpty()) {
                
                    for(Gear_Order_Item__c lineItem : lineItems) {                    
                        System.debug('ProcessInventory_GearOrderUnfulfilled - lineItem: ' + lineItem);
                    
                        // get product for this line item. use product in productsToUpdateMap if it exists
                        Product__c product = null;
                        if (productsToUpdateMap.containsKey(lineItem.Product__c)) {
                            product = productsToUpdateMap.get(lineItem.Product__c);
                        } else {
                            product = productMap.get(lineItem.Product__c);
                        }       
                        if (product.Item_Bundle__c == null) { product.Item_Bundle__c = 1; }
                        System.debug('ProcessInventory_GearOrderUnfulfilled - lineItem product: ' + product);                         
                        
                        // set line item to 'unfulfilled'
                        lineItem.Fulfilled__c = false;
                        orderItemsToUpdateList.add(lineItem);
                        
                        // update product quantity needed - subtract the full quantity for this line item
                        product.Quantity_Needed__c = product.Quantity_Needed__c - (lineItem.Quantity__c * product.Item_Bundle__c);
                        if (product.Quantity_Needed__c < 0) { product.Quantity_Needed__c = 0; }
                        
                        System.debug('ProcessInventory_GearOrderUnfulfilled - new product quantities: ' + product);
                        productsToUpdateMap.put(product.Id, product);
                        
                    } // end for line items
                    
                } // end if line items
                
            } // end for orders
            
            // update order line items
            update orderItemsToUpdateList;
            System.debug('ProcessInventory_GearOrderUnfulfilled - gear order line items unfulfilled: ' + orderItemsToUpdateList);
            
            // update product quantities
            List<Product__c> productsToUpdate = productsToUpdateMap.values();
            update productsToUpdate;
            System.debug('ProcessInventory_GearOrderUnfulfilled - product quantities updated: ' + productsToUpdate.size());
            
        } // end if orders
        
    } // end unfulfillGearOrderItems   
    
} // end ProcessInventory_GearOrderUnfulfilled