public class GearOrder_EmailTemplate_Controller {

    public Gear_Order__c order { get; set; }
    
    /** getOrderSummarizedByProduct
     * returns list for populating summary table of products ordered for this gear order
     * list item (ProductSummary): product category, product name, quantity, list of demographics, list of comments
     * quantity = total number (sum) of this product ordered for this gear order
     * list of demographics and list of comments are lined up together. meaning, each comments[i] is for the child represented in demographics[i]
     */
	public List<ProductSummary> getOrderSummarizedByProduct() {
        
        /*
        // unit test
        if (order == null) {
            order = new Gear_Order__c(ID='a021I00000B6sd4QAB');
        }
		*/
        
        String orderID = order.Id;
        System.debug('GearOrder_EmailTemplate_Controller > getOrderSummarizedByProduct - orderID: ' + orderID);
                
        List<Gear_Order_Item__c> orderItemList = 
            [SELECT Id, Name, Gear_Order_Demographic__c, Product__r.Id, Product__r.Name, Product__r.Family__c, Quantity__c, Season__c, Clothing_Size__c, Diaper_Size__c, Diaper_Swim_Size__c, Comment__c 
             FROM Gear_Order_Item__c WHERE Gear_Order__c = :order.Id ORDER BY Product__r.Family__c ASC];
            
        Map<String, ProductSummary> productMap = new Map<String, ProductSummary>();
        Map<ID, Gear_Order_Demographic__c> demographicsMap = getOrderDemographicsMap(orderID);
            
        // create map of product summaries
        for (Integer i = 0; i < orderItemList.size(); ++i) {
            
            Gear_Order_Item__c orderItem = orderItemList.get(i);
            String productName = orderItem.Product__r.Name;
        
            //System.debug('GearOrder_EmailTemplate_Controller > getOrderSummarizedByProduct - (orderItem ' + i + ') productName: ' + productName);
            
            ProductSummary productMapEntry = productMap.get(productName);
            if (productMapEntry == null) {
                
                // create map entry
                productMapEntry = new ProductSummary();
        		productMapEntry.productCategory = orderItem.Product__r.Family__c;
        		productMapEntry.productName = productName;
        		productMapEntry.quantity = orderItem.Quantity__c;
                
                // orderItemDetails
                productMapEntry.orderItemDetails = new List<ProductSummary.OrderItemDetail>();
                ProductSummary.OrderItemDetail orderItemDetail = new ProductSummary.OrderItemDetail();
				orderItemDetail.demographic = demographicsMap.get(orderItem.Gear_Order_Demographic__c);
				orderItemDetail.orderItem = orderItem;
				productMapEntry.orderItemDetails.add(orderItemDetail);
                
                // add to map
                productMap.put(productName, productMapEntry);
                
            } else { // update map entry
                
                // quantity sum
                productMapEntry.quantity += orderItem.Quantity__c;
                
                // orderItemDetails
                ProductSummary.OrderItemDetail orderItemDetail = new ProductSummary.OrderItemDetail();
				orderItemDetail.demographic = demographicsMap.get(orderItem.Gear_Order_Demographic__c);
				orderItemDetail.orderItem = orderItem;              
                productMapEntry.orderItemDetails.add(orderItemDetail);    
                
            }
            
        } // end for order items
        
        // productSummaryList - from productMap
        List<ProductSummary> productSummaryList = new List<ProductSummary>();
        
        for (String productName : productMap.keySet()) {
			productSummaryList.add(productMap.get(productName));
		}
        
        return productSummaryList;
        
    } // end getOrderSummarizedByProduct
    
    private Map<ID, Gear_Order_Demographic__c> getOrderDemographicsMap(String orderID) {
                
        List<Gear_Order_Demographic__c> demographicsList =
            [SELECT Child_Age__c, Child_Gender__c, Child_Race_Ethnicity__c, Comment__c FROM Gear_Order_Demographic__c WHERE Gear_Order__c = :orderID];  
		
        Map<ID, Gear_Order_Demographic__c> demographicsMap = new Map<ID, Gear_Order_Demographic__c>();   
        
		// create map of demographics
        for (Integer i = 0; i < demographicsList.size(); ++i) {             
            Gear_Order_Demographic__c demographic = demographicsList.get(i);            
            demographicsMap.put(demographic.Id, demographic);            
        }
            
        return demographicsMap;
        
    } // end getDemographicsMap 
    
} // end GearOrder_EmailTemplate_Controller