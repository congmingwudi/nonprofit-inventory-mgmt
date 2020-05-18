({

    getGearOrder: function(component, orderID, orderName) {
        
        // retrieve Gear Order
        console.log('GearOrder_ItemsEditHelper > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);        
        
        // isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);
        
        // Create the action
        var doAction = true;
        var action = component.get("c.getGearOrder"); // method on the GearOrderController
        if (orderID != '') {
            action.setParams({
                "orderID": orderID
            });
        } else if (orderName != '') {
            action.setParams({
                "orderName": orderName
            });            
        } else {
            // no input parameters to find Order
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > getGearOrder response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
               	// orderList                
                var orderList = response.getReturnValue();
            	//console.log('GearOrder_ItemsEditHelper > getGearOrder - orderList: ' + JSON.stringify(orderList));
                
                if (orderList.length > 0) {
                    var order = orderList[0];
                    component.set("v.order", order);
                    component.set("v.orderID", order.Id);
                    component.set("v.orderName", order.Name);
                    
                    this.getDemographicSelection(component, order.Id);
                }
                
            }
            else {
                console.log("GearOrder_ItemsEditHelper > getGearOrder - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end getGearOrder     
    
    getDemographicSelection: function(component, orderID) {
        
        // return
        var demographicsList = null; 
        
        // retrieve Gear Order Demographics
        console.log('GearOrder_ItemsEditHelper > getDemographicSelection - orderID: ' + orderID);        
        
        // Create the action
        var doAction = true;
        var action = component.get("c.getGearOrderDemographicSelection"); // method on the GearOrderController
        if (orderID != '') {
            action.setParams({
                "orderID": orderID
            });
        } else {
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > getDemographicSelection response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // demographicsList                
                demographicsList = response.getReturnValue();
            	//console.log('GearOrder_ItemsEditHelper > getDemographicSelection response demographicsList: ' + JSON.stringify(demographicsList));                
                
                if (demographicsList.length > 0) {
                    
                    // build option list
                    var optionList = new Array();
                    for (var i = 0; i < demographicsList.length; ++i) {
                        var demographic = demographicsList[i];
                        var demographicLabel = demographic.Child_Alias__c + ' | Gender: ' + demographic.Child_Gender__c + ' | Age: ' + demographic.Child_Age__c + ' | Ethnicity: ' + demographic.Child_Race_Ethnicity__c ;                     
                        optionList.push({'label': demographicLabel, 'Id': demographic.Id});                 
                    }      
                 
                    // if no demographic is selected, select the first one
                    // else keep selected demographic
                    var demographicID = component.get("v.demographicID");
                    console.log('GearOrder_ItemsEditHelper > getDemographicSelection - demographicID: "' + demographicID + '"');                
                
                   if (!demographicID || (demographic == "")) {
                        optionList[0].selected = true;
                        demographicID = optionList[0].Id;
                        component.set("v.demographicID", demographicID);
                        console.log('GearOrder_ItemsEditHelper > getDemographicSelection - demographicID selected: ["' + component.get("v.demographicID") + '"');                
                    } else {
                        for (var i = 0; i < optionList.length; ++i) {
                            var option = optionList[i];
                            if (option.Id == demographicID) {
                                optionList[i].selected = true;
                            }
                        }
                    }
                    component.set("v.isDemographicSelected", true);
                } 
                
				console.log('GearOrder_ItemsEditHelper > getDemographicSelection > optionList: ' + JSON.stringify(optionList));
                component.set("v.demographicOptionList", optionList);
                
                // retrieve all order items, and load table with the order items for the selected demographic
                this.getGearOrderItems(component, orderID);
            }
            else {
                console.log("GearOrder_ItemsEditHelper > getDemographicSelection - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
        if (demographicsList == null) {
            demographicsList = new Array();
        }
        
        return demographicsList;
        
    }, // end getDemographicSelection 
    
    saveOrderComment: function(component, orderID, comment) {
        
        console.log('GearOrder_DemographicsEditHelper > saveOrderComment - orderID: ' + orderID + ', comment: ' + comment);        
        
        // Create the action
        var doAction = true;
        var action = component.get("c.updateOrderComment"); // method on the GearOrderController
        if ((orderID != '') && (comment != '')) {
            action.setParams({
                "orderID": orderID,
                "comment": comment
            });        
        } else {
            // required input parameters missing
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > saveOrderComment - response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {                
               	// responseStatus                
                var responseStatus = response.getReturnValue();
            	console.log('GearOrder_DemographicsEditHelper > saveOrderComment - responseStatus: ' + JSON.stringify(responseStatus));           
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > saveOrderComment - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end saveOrderComment     
           
    getGearOrderItems: function(component, orderID) {
        // retrieve all order items, and load table with the order items for the selected demographic        

        // outcome is setting this value into the component attribute 'orderItemList'
        var orderItemList = null; 
        
        // retrieve Gear Order Items
        console.log('GearOrder_ItemsEditHelper > getGearOrderItems - orderID: ' + orderID);        

		// isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);
        
        // Create the action
        var doAction = true;
        var action = component.get("c.getGearOrderItems"); // method on the GearOrderController
        if (orderID != '') {
            action.setParams({
                "orderID": orderID
            });
        } else {
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > getGearOrderItems - response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // orderItemList                
                orderItemList = response.getReturnValue();
            	console.log('GearOrder_ItemsEditHelper > getGearOrderItems - orderItemList: ' + JSON.stringify(orderItemList));                
                component.set("v.orderItemList", orderItemList);
                
                // set table data
                var demographicID = component.get("v.demographicID");
                this.setOrderItemsTableData(component, demographicID, orderItemList);
            }
            else {
                console.log("GearOrder_ItemsEditHelper > getGearOrderItems - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }

        
    }, // end getGearOrderItems  
    
	demographicSelected: function(component, demographicID) {
        
        console.log('GearOrder_ItemsEditHelper > demographicSelected - demographicID: ' + demographicID);

        var orderItemList = component.get("v.orderItemList");
        this.setOrderItemsTableData(component, demographicID, orderItemList);
        component.set("v.isDemographicSelected", true);
 
    }, // end demographicSelected       
    
    // FOR ORDER ITEM TABLE
    
    setOrderItemsTableData: function(component, demographicID, orderItemList) {
        
        console.log('GearOrder_ItemsEditHelper > setOrderItemsTableData - demographicID: ' + demographicID + ', orderItemList: ' + orderItemList.length);  
        //console.log('GearOrder_ItemsEditHelper > setOrderItemsTableData - demographicID: ' + demographicID + ', orderItemList: ' + JSON.stringify(orderItemList));  
        
        // subset of order item data and only items for the selected demographic
        var data = Array();        
        for (var i = 0; i < orderItemList.length; ++i) {
            var item = orderItemList[i];
            
            if (item.Gear_Order_Demographic__c == demographicID) {
                var dataItem = {};
                dataItem.Name = item.Name;
                dataItem.ProductCategory = item.Product__r.Family__c;
                dataItem.ProductName = item.Product__r.Name;
                dataItem.Quantity = item.Quantity__c;
                data.push(dataItem);
        	}
        }
        console.log('GearOrder_ItemsEditHelper > setOrderItemsTableData - data: ' + JSON.stringify(data));  
        
        // set table data
        component.set('v.numOrderItemsForDemographic', data.length);
        component.set('v.tableData', data);
                        
        // stop the spinner
        component.set('v.isLoading', false);
        
        // sort table by order item 'Name'
        var fieldName = 'Name';
        var sortDirection = 'asc';
        var showLoadingSpinner = false;
        this.updateColumnSorting(component, fieldName, sortDirection, showLoadingSpinner);
        
        console.log('GearOrder_ItemsEditHelper > setOrderItemsTableData - complete');
                    
    }, // end setOrderItemsTableData  

    updateColumnSorting: function(component, fieldName, sortDirection, showLoadingSpinner) {
        // show loading spinner
		if (showLoadingSpinner) component.set('v.isLoading', true);
        
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        // Using var for 'this' because 'this.sortData' within the anonymous function isn't recognized
        // because 'this' inside the anonymous function is empty
        var helper = this; 
        setTimeout(function() {            
            console.log('GearOrder_ItemsEditHelper > sort - fieldName: ' + fieldName + ', sortDirection: ' + sortDirection);
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            var data = component.get("v.tableData");
            data = helper.sortData(data, fieldName, sortDirection);
            component.set("v.tableData", data);
            
            // hide loading spinner
            if (showLoadingSpinner) component.set('v.isLoading', false);
        }, 0);        
        
    }, // end updateColumnSorting
    
    sortData: function (data, fieldName, sortDirection) {
        
        var reverse = sortDirection !== 'asc';
        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        return data;
        
    }, // end sortData
    
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    }, // end sortBy   
    
    // FOR MODAL DIALOG
    
    openModel_AddOrderItem: function(component) {
                            
        // init order item
        var orderItem = {};
        orderItem.Quantity__c = 1;
        component.set("v.orderItem", orderItem);
        console.log('GearOrder_ItemsEditController > openModel_AddOrderItem - init order item: ' + JSON.stringify(orderItem));
            
        // demographic
        var demographicID = component.get('v.demographicID');
        component.set("v.orderItem.Gear_Order_Demographic__c", demographicID);
        console.log('GearOrder_ItemsEditController > openModel_AddOrderItem - demographicID: ' + demographicID);
        
        // product selection
        var productList = component.get('v.orderItem_productOptionList');
        console.log('GearOrder_ItemsEditController > openModel_AddOrderItem - productList: ' + JSON.stringify(productList));
        var productID = productList[0].Id;
        component.set('v.orderItem.Product__c', productID);
        this.productSelected(component, productID);  
        console.log('GearOrder_ItemsEditController > openModel_AddOrderItem - product selection: ' + JSON.stringify(component.get('v.orderItem.Product__c')));        
        
        // open modal 
        component.set('v.orderItem_modalAction', 'create');
        component.set('v.orderItem_modalTitle', 'Add Order Item');
        component.set('v.orderItem_readonly', false);
    	component.set("v.isOpen", true);
            
   	}, // end openModel_AddOrderItem
    
	getProductSelection: function(component) {
        
        console.log('GearOrder_ItemsEditHelper > getProductSelection');        
        
        // Create the action
        var action = component.get("c.getProductSelection"); // method on the GearOrderController
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > getProductSelection response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // productList                
                var productList = response.getReturnValue();
            	//console.log('GearOrder_ItemsEditHelper > getProductSelection: ' + JSON.stringify(productList)); 

				// productMap
                var productMap = new Map();
                
                for (var i = 0; i < productList.length; ++i) {
                    var product = productList[i];
                    var category = product.Family__c;
                    var categoryProductList = null;
                    if (productMap.get(category) == undefined) {
                        categoryProductList = new Array();
                    } else {
                        categoryProductList = productMap.get(category);                        
                    }
                    categoryProductList.push(product);
                    productMap.set(category, categoryProductList); 
                }                
                //console.log('GearOrder_ItemsEditHelper > productMap: ' + JSON.stringify(productMap));

                // sort categories alphabetically
                productMap = this.sortProductCategories(productMap);
                
                var optionList = new Array();
                for (var [key, value] of productMap) {
                    var categoryLabel = 'CATEGORY: ' + key.toUpperCase();
                    optionList.push({'label': '------ ' + categoryLabel + ' ------', 'Id': categoryLabel});
                    var products = value;
                    for (var i = 0; i < products.length; ++i) {
                        var product = products[i];
                        optionList.push({'label': product.Name, 'Id': product.Id, 'itemBundle': product.Item_Bundle__c});
                    }
				}
				//console.log('GearOrder_ItemsEditHelper > optionList: ' + JSON.stringify(optionList));

                component.set("v.orderItem_productOptionList", optionList);
                
            }
            else {
                console.log("GearOrder_ItemsEditHelper > getProductSelection - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end getProductSelection 
    
    sortProductCategories: function(productMap) {

    	console.log('GearOrder_ItemsEditHelper > sortProductCategories');

        // create category array similar to the data table data for sorting
		var data = Array();        
        for (var [key, value] of productMap) {     
            var dataItem = {};
            dataItem.category = key;
            data.push(dataItem);
        }
        
        // sort categories
        var fieldName = 'category';
        var sortDirection = 'asc';
    	data = this.sortData(data, fieldName, sortDirection);
        
        // create new productMap with the sorted categories
        var newProductMap = new Map();
        for (var i = 0; i < data.length; ++i) {
            var category = data[i].category;
            //console.log('category ' + i + ': ' + category);
            
            for (var [key, value] of productMap) {
                if (key == category) {
                    var categoryProductList = productMap.get(category); 
                    newProductMap.set(category, categoryProductList); 
                }
            }
        } // end for sorted categories
        
        return newProductMap;
        
    }, // end sortProductCategories
    
    createGearOrderItem: function(component, orderItem) {
        
        console.log('GearOrder_ItemsEditHelper > createGearOrderItem - ' + JSON.stringify(orderItem));
        
        // Create the action
        var action = component.get("c.createGearOrderItem"); // method on the GearOrderController
        action.setParams({
            "orderID": orderItem.Gear_Order__c,
            "demographicID": orderItem.Gear_Order_Demographic__c,
            "productID": orderItem.Product__c,
            "quantity": orderItem.Quantity__c,
            "season": orderItem.Season__c,
            "clothingSize": orderItem.Clothing_Size__c,
            "diaperSize": orderItem.Diaper_Size__c,
            "comment": orderItem.Comment__c
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > createGearOrderItem response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderItem = response.getReturnValue();
                var orderID = orderItem.Gear_Order__c;
                console.log('GearOrder_ItemsEditHelper > createGearOrderItem - orderItem created: ' + JSON.stringify(orderItem));
                
                // refresh gear order items to show updated list of order items
                //this.getGearOrder(component, orderID);
                this.getGearOrderItems(component, orderID);
            }
            else {
                console.log("GearOrder_ItemsEditHelper > createGearOrderItem - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end createGearOrderItem

    updateGearOrderItem: function(component, orderItem) {
        
        console.log('GearOrder_ItemsEditHelper > updateGearOrderItem - ' + JSON.stringify(orderItem));
        
        // Create the action
        var action = component.get("c.updateGearOrderItem"); // method on the GearOrderController
        action.setParams({
            "orderID": orderItem.Gear_Order__c, // only passed in so that it will be returned with the orderItem
            "orderItemID": orderItem.Id,
            "productID": orderItem.Product__c,
            "quantity": orderItem.Quantity__c,
            "season": orderItem.Season__c,
            "clothingSize": orderItem.Clothing_Size__c,
            "diaperSize": orderItem.Diaper_Size__c,
            "comment": orderItem.Comment__c
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > updateGearOrderItem response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderItem = response.getReturnValue();
                var orderID = orderItem.Gear_Order__c;
                console.log('GearOrder_ItemsEditHelper > updateGearOrderItem - orderItem updated: ' + JSON.stringify(orderItem));
                
                // refresh gear order to show updated list of order items
                this.getGearOrder(component, orderID);
            }
            else {
                console.log("GearOrder_ItemsEditHelper > createGearOrderItem - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end updateGearOrderItem    

    deleteGearOrderItem: function(component, orderItem) {
        
        console.log('GearOrder_ItemsEditHelper > deleteGearOrderItem - ' + JSON.stringify(orderItem));
        
        // Create the action
        var action = component.get("c.deleteGearOrderItem"); // method on the GearOrderController
        action.setParams({
            "orderID": orderItem.Gear_Order__c, // only passed in so that it will be returned with the orderItem
            "orderItemID": orderItem.Id
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > deleteGearOrderItem response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderItem = response.getReturnValue();
                var orderID = orderItem.Gear_Order__c;
                console.log('GearOrder_ItemsEditHelper > deleteGearOrderItem - orderItem deleted: ' + JSON.stringify(orderItem));
                
                // refresh gear order to show updated list of order items
                this.getGearOrder(component, orderID);
            }
            else {
                console.log("GearOrder_ItemsEditHelper > createGearOrderItem - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end deleteGearOrderItem
    
    setOrderItemFields: function(component, orderItemRow) {
        console.log('GearOrder_ItemsEditHelper > orderItemRow: ' + JSON.stringify(orderItemRow));
        
        // get orderItem
        var orderItem;
        var orderItemList = component.get("v.orderItemList");
        //console.log('GearOrder_ItemsEditHelper > orderItemList: ' + JSON.stringify(orderItemList));
        for (var i = 0; i < orderItemList.length; ++i) {
            var item = orderItemList[i];
            if (item.Name == orderItemRow.Name) {
                orderItem = item;
            }
        }
        console.log('GearOrder_ItemsEditHelper > orderItem: ' + JSON.stringify(orderItem));
        
        // show additional fields by product name
        var productID = orderItem.Product__c;
        this.productSelected(component, productID);
        
        // update orderItem attribute
        component.set("v.orderItem", orderItem);

    }, // setOrderItemFields
    
	productSelected: function(component, productID) {
        
        console.log('GearOrder_ItemsEditHelper > productSelected - productID: ' + productID);
        
        if (productID.startsWith('CATEGORY')) {
            // category selected
            component.set("v.isCategory", true);
            
            // hide additional order item fields
            component.set("v.isClothing", false);
            component.set("v.isDiapers", false);
        } else {
            // product selected 
            component.set("v.isCategory", false);
            
            // product name
            var product;
            var productList = component.get('v.orderItem_productOptionList');
            for (var i = 0; i < productList.length; ++i) {
                var p = productList[i];
                if (productID == p.Id) {
                    //productName = productList[i].label; 
                    product = p;             
                }
            }   
            console.log('GearOrder_ItemsEditHelper > productSelected: ' + JSON.stringify(product)); 
            
            // show additional fields by product name
            this.showAdditionalOrderItemFields(component, product);            
        }
 
    }, // end productSelected 
    
    showAdditionalOrderItemFields: function(component, product) {
        
        var productName = product.label;
        var itemBundle = product.itemBundle;
        
        // label - quantity/bundle
        var quantityLabel;
        if ((itemBundle) && itemBundle > 1) { 
            quantityLabel = "Bundles (" + itemBundle + " items per bundle)";
        } else { 
            quantityLabel = "Quantity"; 
        }
        component.set("v.orderItem_quantityLabel", quantityLabel);
        
        // check 'clothing' (any product name that contains 'clothing')
        if (productName.toLowerCase().search('clothing') != -1) {
            console.log('GearOrder_ItemsEditHelper > showAdditionalOrderItemFields - product is clothing');
            component.set("v.isClothing", true);
        } else {
            component.set("v.isClothing", false);
        }
        
        // check 'diapers' (product is named 'diapers' only)
        if (productName.toLowerCase() == 'diapers') {
            console.log('GearOrder_ItemsEditHelper > showAdditionalOrderItemFields - product is diapers: ' + productName);  
            component.set("v.isDiapers", true);
        } else {
            component.set("v.isDiapers", false);
        }        
        
    }, // end showAdditionalOrderItemFields
    
    loadPicklistValues: function(component) {
        var componentAttribute;
        var objectName;
        var field;
                
        // season options
        componentAttribute = 'orderItem_seasonOptionList';
        objectName = 'Gear_Order_Item__c';
        field = 'Season__c';
        this.getPicklistValues(component, componentAttribute, objectName, field); 
        
        // clothingSize options
        componentAttribute = 'orderItem_clothingSizeOptionList';
        objectName = 'Gear_Order_Item__c';
        field = 'Clothing_Size__c';
        this.getPicklistValues(component, componentAttribute, objectName, field); 
        
        // diaperSize options
        componentAttribute = 'orderItem_diaperSizeOptionList';
        objectName = 'Gear_Order_Item__c';
        field = 'Diaper_Size__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
    }, // end loadPicklistValues
    
    getPicklistValues: function(component, componentAttribute, objectName, field) {
        
        console.log('GearOrder_ItemsEditHelper > getPicklistValues - componentAttribute: ' + componentAttribute + ', objectName: ' + objectName + ', field: ' + field);
        
        // Create the action
        var action = component.get("c.getPicklistValues"); // method on the GearOrderController
        action.setParams({
            "obj": {sobjectType : objectName},
            "field": field
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_ItemsEditHelper > getPicklistValues response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                console.log('GearOrder_ItemsEditHelper > getPicklistValues - returnValue: ' + JSON.stringify(options));
            	component.set("v." + componentAttribute, options);
            }
            else {
                console.log("GearOrder_ItemsEditHelper > getPicklistValues - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end getPicklistValues

    validateFields: function (component) {
        
        var allGood = true;
        var errorMessage = "";

        // check that each demographic has at least one order item
        var demographicOptionList = component.get("v.demographicOptionList");
        var orderItemList = component.get("v.orderItemList");
        var demographicID;
       
        for (var i = 0; i < demographicOptionList.length; ++i) {
        	demographicID = demographicOptionList[i].Id;
            var demographicHasOrderItems = false;
            
            for (var j = 0; j < orderItemList.length; ++j) {
            	if (orderItemList[j].Gear_Order_Demographic__c == demographicID) {
                    demographicHasOrderItems = true;
                    break; // no need to continue loop if an order item is found for this demographic
                }
            } // end for orderItemList 
                     
            console.log("GearOrder_ItemsEditHelper > validateFields - demographicID: " + demographicID + ", demographicHasOrderItems: " + demographicHasOrderItems);
            if (!demographicHasOrderItems) {
                allGood = false;
                break; // no need to continue loop if any demographic has zero order items
            }
            
        } // end for demographicOptionList
        
        if (!allGood) {
        	errorMessage = "Please enter at least one order item for each demographic to continue.";
            
            // select the first demographic found that has no order items
            component.set("v.demographicID", demographicID);
            this.demographicSelected(component, demographicID); 
        }
        component.set("v.errorMessage", errorMessage);
                      
		return allGood;
        
	}, // end validateFields    
       
});