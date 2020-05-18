({
	getGearOrder: function(component, orderID, orderName) {
        
        // retrieve Gear Order
        console.log('GearOrder_SubmittedHelper > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);        
               
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
            console.log('GearOrder_SubmittedHelper > getGearOrder response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
               	// orderList                
                var orderList = response.getReturnValue();
            	//console.log('GearOrder_SubmittedHelper > getGearOrder - orderList: ' + JSON.stringify(orderList));
                
                if (orderList.length > 0) {
                    var order = orderList[0];
                    component.set("v.order", order);
                    component.set("v.orderID", order.Id);
                    component.set("v.orderName", order.Name);
                }
                
            }
            else {
                console.log("GearOrder_SubmittedHelper > getGearOrder - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end getGearOrder   
})