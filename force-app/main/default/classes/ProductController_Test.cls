@isTest
private class ProductController_Test {

    @isTest static void test_getPartnerOrgSelection() {
        
        System.debug('ProductController_Test >> test_getGearOrder > start');
    	List<Product__c> productList = ProductController.getProducts();
        System.debug('ProductController_Test >> test_getGearOrder > productList: ' + productList);
    }

}