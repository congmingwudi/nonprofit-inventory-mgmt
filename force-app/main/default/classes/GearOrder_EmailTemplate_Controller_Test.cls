@isTest
public class GearOrder_EmailTemplate_Controller_Test {

    @isTest static void test_getOrderSummarizedByProduct() {
        
        System.debug('GearOrder_EmailTemplate_Controller_Test >> test_getOrderSummarizedByProduct > start');
        
        // partner organization
        Account partnerOrg = new Account(Name='Test Partner Organization');
        insert partnerOrg;
        
        // order
        Gear_Order__c order = new Gear_Order__c(Partner_Organization__c=partnerOrg.Id,
                                               Order_Created__c=dateTime.now());
        insert order;
        String orderID = order.Id;
        
        // product
        Product__c product = new Product__c(Family__c='None', Name='TestProduct1', Value__c=1,Weight__c=1); 
        insert product;
        
        // gear order demographics
        Integer childNum = 0;
        String childAlias = 'Child ' + (++childNum);
        String childGender = 'Unknown';
        String childAge = 'Unknown';
        String childRaceEthnicity = 'Other/Unknown';
        String parentGender = 'Unknown';
        String parentAge = 'Unknown';
        String parentRaceEthnicity = 'Other/Unknown';
        String parentMaritalStatus = 'Unknown';
        String demographicComment = 'test comment';
        
        Gear_Order_Demographic__c demographic = GearOrderDemographicsController.createGearOrderDemographic(orderID, childAlias, 
            childGender, childAge, childRaceEthnicity,parentGender, parentAge, parentRaceEthnicity, parentMaritalStatus, 
            demographicComment);

		// order items        	 
        
        // orderItem 1 - product 1
        String demographicID = demographic.Id;
        String productID = product.Id;
        Integer quantity = 1;
        String comment = 'test comment 1';
        Gear_Order_Item__c orderItem1 = GearOrderController.createGearOrderItem(orderID, demographicID, productID, quantity, null, null, null, comment);               
        
        // orderItem 2 - product 1
        demographicID = null;
        productID = product.Id;
        quantity = 1;
        comment = 'test comment 2';
        Gear_Order_Item__c orderItem2 = GearOrderController.createGearOrderItem(orderID, demographicID, productID, quantity, null, null, null, comment);               
        
        // getOrderSummarizedByProduct
        GearOrder_EmailTemplate_Controller controller = new GearOrder_EmailTemplate_Controller();
        controller.order = order;
        List<ProductSummary> productSummaryList = controller.getOrderSummarizedByProduct();
        System.debug('GearOrder_EmailTemplate_Controller_Test > test_getOrderSummarizedByProduct: ' + productSummaryList);

        // test ProductSummary get methods
        for (Integer i = 0; i < productSummaryList.size(); ++i) {
            ProductSummary summary = productSummaryList.get(0);
            System.debug('productSummary ' + i + ' - Category: ' + summary.productCategory + ', Product: ' + summary.productName + ', Quantity: ' + summary.quantity);  
			List<ProductSummary.OrderItemDetail> orderItemDetails = summary.orderItemDetails;
            for (Integer j = 0; j < orderItemDetails.size(); ++j) {
                ProductSummary.OrderItemDetail orderItemDetail = orderItemDetails.get(0);
                System.debug('\t orderItemDetail ' + j + ' - Demographic: ' + orderItemDetail.demographicDisplay + ', Details: ' + orderItemDetail.orderItemDisplay + ', Comments: ' + orderItemDetail.commentsDisplay);
            }
        }
        
    } // end test_getOrderSummarizedByProduct 
    
} // end GearOrder_EmailTemplate_Controller_Test