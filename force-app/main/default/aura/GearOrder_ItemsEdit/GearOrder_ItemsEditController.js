({
    init: function(component, event, helper) {
        
        console.log('GearOrder_ItemsEditController > init');        

    	component.set('v.tableColumns', [
            {label: 'Order Item ID', fieldName: 'Name', type: 'text', sortable: true, iconName: "standard:lead_list", cellAttributes: { alignment: 'left' } },
            {label: 'Category', fieldName: 'ProductCategory', type: 'text', sortable: true, iconName: "standard:record", cellAttributes: { alignment: 'left' } },
            {label: 'Product', fieldName: 'ProductName', type: 'text', sortable: true, iconName: "standard:product_item", cellAttributes: { alignment: 'left' } },
            {type:  'button', typeAttributes: {iconName: 'utility:edit', label: '', name: 'edit', disabled: false}, cellAttributes: { alignment: 'center' } },
            {type:  'button', typeAttributes: {iconName: 'utility:delete', label: '', name: 'delete', disabled: false}, cellAttributes: { alignment: 'center' }},
            ]);                
        
        // load Gear Order (this pulls in demographics and order line items)
        var orderID = component.get("v.orderID");
        var orderName = component.get("v.orderName");
		helper.getGearOrder(component, orderID, orderName);
        
        // load product selection
        helper.getProductSelection(component);
        
        // load picklist values
        helper.loadPicklistValues(component);
        
    }, // end init
            
	handleNavigation : function(component, event, helper) {
            
        var allGood;    

        // set 'navigation' attribute that the flow will use to determine flow path
        var buttonClicked = event.getSource().getLocalId();
        component.set('v.navigation', buttonClicked);      
        console.log('GearOrder_ItemsEditController > handleNavigation - clicked: ' + buttonClicked);
        
        if (buttonClicked == "nav_pickupTimes") {
            // do field validation
			allGood = helper.validateFields(component);
      		console.log('GearOrder_ItemsEditController > handleNavigation - allGood: ' + allGood);
        } else {
            // skip the field validation for all other buttons
        	allGood = true; 
        }
            
      	if (allGood) {
        	// go forward in the flow; this does the same thing as the "Next" button in the standard flow footer      
        	var navigate = component.get("v.navigateFlow");
        	if (navigate) {
        		navigate("NEXT");      
        	}
    	} 
            
   	}, // end handleNavigation 
            
    demographicSelected: function(component, event, helper) {
        
		var demographicID = component.find("demographicSelection").get("v.value");
        console.log('GearOrder_ItemsEditController > demographic selected - demographicID: ' + demographicID);
		helper.demographicSelected(component, demographicID);
  
    }, // end demographicSelected           

    saveOrderComment: function (component, event, helper) { 
            
        var orderID = component.get('v.orderID');
        var comment = component.get('v.order.Comment__c');
        console.log('GearOrder_DemographicsEditController > saveOrderComment - orderID: ' + orderID + ', comment: ' + comment);         
        helper.saveOrderComment(component, orderID, comment) ; 
            
    }, // end saveOrderComment
            
    // ORDER ITEM TABLE OPERATIONS
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var showLoadingSpinner = true;
        helper.updateColumnSorting(component, fieldName, sortDirection, showLoadingSpinner);
    }, // end updateColumnSorting
            
    handleRowAction: function (component, event, helper) {
            
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('GearOrder_ItemsEditController > row action: ' + JSON.stringify(action));

        switch (action.name) {
            case 'edit': {
            	console.log('GearOrder_ItemsEditController > edit order item: ' + JSON.stringify(row));                
                helper.setOrderItemFields(component, row);
                
                // open modal
                component.set('v.orderItem_modalAction', 'update');
                component.set('v.orderItem_modalTitle', 'Edit Order Item');
            	component.set('v.orderItem_readonly', false);
    			component.set("v.isOpen", true);
                break;
            }
            case 'delete': {
            	console.log('GearOrder_ItemsEditController > delete order item: ' + JSON.stringify(row));                
                helper.setOrderItemFields(component, row);               
                               
                // open modal
                component.set('v.orderItem_modalAction', 'delete');
                component.set('v.orderItem_modalTitle', 'Delete Order Item');
            	component.set('v.orderItem_readonly', true);
    			component.set("v.isOpen", true);
                break;
        	}
        } // end switch
            
    }, // end handleRowAction
            
    isLoadingChanged: function(component, event, helper) {   
            
        var isLoading = event.getParam("value");
        console.log('GearOrder_ItemsEditController > isLoadingChanged: ' + isLoading); 
        
        if (!isLoading) {  
            // handle reopen Add Order Item modal
            var orderItem_modalReopen = component.get("v.orderItem_modalReopen");
            if (orderItem_modalReopen) {
                helper.openModel_AddOrderItem(component);
                component.set("v.orderItem_modalReopen", false); // reset to false
            }
        }
            
   	}, // end isLoadingChanged 
            
    
    // MODEL OPERATIONS
        
    openModel_AddOrderItem: function(component, event, helper) {
    	helper.openModel_AddOrderItem(component);
   	}, // end openModel_AddOrderItem
    
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
    }, // end closeModel 
    
    saveOrderItem: function(component, event, helper) {
            
        var modalAction = component.get('v.orderItem_modalAction');
        var order = component.get("v.order");
        var orderID = order.Id;
        var buttonClicked = event.getSource().getLocalId(); 
        console.log('GearOrder_ItemsEditController > saveOrderItem (' + modalAction + ' / ' + buttonClicked + ') - for orderID: ' + orderID);
        
        var doSave = false;
        
        var orderItem = component.get("v.orderItem");
        orderItem.Gear_Order__c = orderID;
        
        // product
		var productID = orderItem.Product__c;
        console.log('GearOrder_ItemsEditController > saveOrderItem (' + modalAction + ') - product selected: ' + productID);
               
        // validate product selection        
        if (productID.startsWith('CATEGORY')) {
            var errors = [{'message':'You selected a category. Please select a product.'}];
            component.set("v.orderItem_errors", errors);
		} else {            
            // clear error
    		component.set("v.orderItem_errors", null);
            doSave = true;
		}
        
        if (doSave) {
            // store order item
            console.log('GearOrder_ItemsEditController > saveOrderItem (' + modalAction + ') - orderItem: ' + JSON.stringify(orderItem));
            if (modalAction == 'create') {
            	helper.createGearOrderItem(component, orderItem);
            } else if (modalAction == 'update') {
            	helper.updateGearOrderItem(component, orderItem);
            } 
    
            if (buttonClicked == "button_saveAddAnotherOrderItem") {
                // use attributes isLoading and orderItem_modalReopen to control the reopening of the modal.
                // when isLoading is set back to false after processing of helper.createGearOrderItem
                // then isLoading is set to false, and it's onchange controller function will reopen the modal
                // if orderItem_modalReopen is true            
                component.set("v.orderItem_modalReopen", true);
        	}
            
            // close modal
           	component.set("v.isOpen", false);
        }
 
    }, // end saveOrderItem

    deleteOrderItem: function(component, event, helper) {
        
        var modalAction = component.get('v.orderItem_modalAction');
        var order = component.get("v.order");
        var orderID = order.Id;
        
        var orderItem = component.get("v.orderItem");
        orderItem.Gear_Order__c = orderID;
        console.log('GearOrder_ItemsEditController > deleteOrderItem (' + modalAction + ') - for orderItem: ' + JSON.stringify(orderItem));
        
        helper.deleteGearOrderItem(component, orderItem);
        
		// close modal
        component.set("v.isOpen", false);
 
    }, // end saveOrderItem    
    
	productSelected: function(component, event, helper) {
        
		var productID = component.find("orderItem_product").get("v.value");
        console.log('GearOrder_ItemsEditController > productSelected - productID: ' + productID);
		helper.productSelected(component, productID);
  
    }, // end productSelected   
    
})