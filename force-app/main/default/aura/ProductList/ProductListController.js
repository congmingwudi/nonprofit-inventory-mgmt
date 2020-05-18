({
    
    init: function(component, event, helper) {
        
        // retrieve Products organized by Category in a Map
        console.log('ProductListController > init')

        // Create the action
        var action = component.get("c.getProducts"); // method on the ProductController

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('ProductListController > init - getProducts response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // productList                
                var productList = response.getReturnValue();
            	//console.log('ProductListController > init - products: ' + JSON.stringify(productList));
                
                // categoryList
                var productMap = new Map();
                var categoryList = new Array();
                
                for (var i = 0; i < productList.length; ++i) {
                    var product = productList[i];
                    var category = product.Family__c;
                    var categoryProductList = null;
                    if (category.toUpperCase() != 'NONE') {
                        if (productMap.get(category) == undefined) {
                            categoryProductList = new Array();
                        } else {
                            categoryProductList = productMap.get(category);
                        }
                        categoryProductList.push(product);
                        productMap.set(category, categoryProductList);
                    }
                }

                // sort categories alphabetically
                productMap = helper.sortProductCategories(productMap);
                
                //console.log('ProductListController > init - productMap: ' + JSON.stringify(productMap));
                //console.log('ProductListController > init - productMap[Gear]: ' + JSON.stringify(productMap.get('Gear')));
                component.set("v.productMap", productMap);
 
                for (var [key, value] of productMap) {
                    categoryList.push(key);
				}
                //console.log('ProductListController > init - categories: ' + JSON.stringify(categoryList));
                component.set("v.categoryList", categoryList);
               
            }
            else {
                console.log("ProductListController > init - failed with state: " + state);
            }
        });

        // Send action off to be executed
        $A.enqueueAction(action);
    } // end init
    
})