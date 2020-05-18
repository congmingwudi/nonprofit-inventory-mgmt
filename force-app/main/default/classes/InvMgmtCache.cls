/**
 * Created by ryan.cox on 2019-02-07.
 *
 * uses platform cache to manage cache entries for the available product list
 * see -> https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_platform_cache_limits.htm
 */

public class InvMgmtCache {

    private static String CACHE_PARTITION = 'local.defaultCache';
    private static Integer CACHE_TTL = 172800; // cache time-to-live in seconds = 48 hours, the max allowed
    private static String PRODUCTS_CACHE_NAME = 'PRODUCTS';

    private Cache.OrgPartition orgCache;

    public InvMgmtCache() {

        // init orgCache
        this.orgCache = Cache.Org.getPartition(CACHE_PARTITION);

        if (this.orgCache == null) {
            System.debug('InvMgmtCache > cache partition ' + CACHE_PARTITION + ' not configured');
        }

    }

    public void putProducts(List<Product__c> productList) {

        if (this.orgCache != null) {
            try {
                this.orgCache.put(PRODUCTS_CACHE_NAME, productList, CACHE_TTL);
                System.debug('InvMgmtCache > putProducts - ' + PRODUCTS_CACHE_NAME + ' stored');
            } catch (Exception e) {
                // problem storing the cache entry - e.g. size of entry > 100KB
                System.debug('InvMgmtCache > putProducts - ' + PRODUCTS_CACHE_NAME + ' exception: ' + e);
            }
        }

    }

    public List<Product__c> getProducts() {

        List<Product__c> productList = null;

        if (this.orgCache != null) {
            productList = (List<Product__c>) this.orgCache.get(PRODUCTS_CACHE_NAME);
            System.debug('InvMgmtCache > getProducts - ' + PRODUCTS_CACHE_NAME + ' found');

            if (productList == null) {
                System.debug('InvMgmtCache > getProducts - ' + PRODUCTS_CACHE_NAME + ' not found');
            }
        }

        return productList;
    }

    public void clearProducts() {

       if (this.orgCache != null) {
            this.orgCache.remove(PRODUCTS_CACHE_NAME);
            System.debug('InvMgmtCache > clearProducts - ' + PRODUCTS_CACHE_NAME + ' removed from cache');
        }
    }

} // end InvMgmtCache