({
	init : function(component, event, helper) {
        
        var key = component.get("v.category");
        //console.log('ProductCategoryController > init - key: ' + key);
        var map = component.get("v.productMap"); 
        //console.log('ProductCategoryController > init - productMap: ' + JSON.stringify(map));
        //console.log('ProductCategoryController > init - productMap[Gear]: ' + JSON.stringify(map.get('Gear')));

        var productList = map.get(key);
        //console.log('ProductCategoryController > init - productList: ' + JSON.stringify(productList));
        component.set("v.productList" , productList);
        
	} // end init
})