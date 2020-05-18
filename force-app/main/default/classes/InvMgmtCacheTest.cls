/**
 * Created by ryan.cox on 2019-02-07.
 */

@isTest
public class InvMgmtCacheTest {

    @isTest static void test_productCache() {

        Test.startTest();

        InvMgmtCache cache = new InvMgmtCache();

        // clear cache
        cache.clearProducts();

        // test w/o cache
        long startTime = System.currentTimeMillis();
        ProductController.getProducts();
        long elapsedTime = System.currentTimeMillis() - startTime;
        System.debug('InvMgmtCacheTest > test_productCache - getProducts w/o cache: ' + elapsedTime);

        // test w/ cache
        startTime = System.currentTimeMillis();
        ProductController.getProducts();
        elapsedTime = System.currentTimeMillis() - startTime;
        System.debug('InvMgmtCacheTest > test_productCache - getProducts w cache: ' + elapsedTime);

        Test.stopTest();

    } // end test_createContact

}