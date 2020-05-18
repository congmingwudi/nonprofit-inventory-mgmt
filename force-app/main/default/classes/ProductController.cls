public with sharing class ProductController {
    
    @AuraEnabled
    public static List<Product__c> getProducts() {

        System.debug('ProductController - getProducts');

        InvMgmtCache cache = new InvMgmtCache();
        List<Product__c> productList = cache.getProducts();

        if (productList == null) { // not in cache

            // query Products__c
            productList = [SELECT Id, Name, Family__c, Item_Bundle__c FROM Product__c WHERE Available_To_Order__c = true ORDER BY Family__c ASC, Name ASC];

            // store in cache
            cache.putProducts(productList);
        }

        return productList;

    } // end getProducts
    
} // end ProductController