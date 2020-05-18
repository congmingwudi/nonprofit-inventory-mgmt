({

    getGearOrder: function(component, orderID, orderName) {
        
        // retrieve Gear Order
        console.log('GearOrder_EnterBulkDemographicsHelper > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);        
        
        // isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);
        
        // Create the action
        var doAction = true;
        var action = component.get("c.getGearOrderForBulkDemographics"); // method on the GearOrderController
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

        if (doAction) {
        
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                console.log('GearOrder_EnterBulkDemographicsHelper > getGearOrder response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // orderList
                    var orderList = response.getReturnValue();
                    //console.log('GearOrder_EnterBulkDemographicsHelper > getGearOrder orderList: ' + JSON.stringify(orderList));

                    if (orderList.length > 0) {
                        var order = orderList[0];
                        component.set("v.order", order);
                        component.set("v.recordId", order.Id);
                        //component.set("v.orderName", order.Name);
                        //component.set("v.numFamiliesServed", order.Num_Families_Served__c);
                        component.set("v.accountID", order.Partner_Organization__c);

                        // get demographics served for the account
                        this.getDemographicsServed(component);
                     }
                }
                else {
                    console.log("GearOrder_EnterBulkDemographicsHelper > getGearOrder - failed with state: " + state);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        } // end doAction
        
    }, // end getGearOrder

    getDemographicsServed: function(component) {

        var accountID = component.get("v.accountID");
        console.log('GearOrder_EnterBulkDemographicsHelper > getDemographicsServed - accountID: ' + accountID);

        // Create the action
        var doAction = true;
        var action = component.get("c.getDemographicsServed"); // method on the GearOrderController
        if (accountID != '') {
            action.setParams({
                "accountID": accountID
            });
        } else {
            // no input parameters to find Order
            doAction = false;
        }

        if (doAction) {

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('GearOrder_EnterBulkDemographicsHelper > getDemographicsServed - response: ' + state)
                if (state === "SUCCESS") {

                    var demographicsServedDetails = response.getReturnValue();
                    console.log('GearOrder_EnterBulkDemographicsHelper > getDemographicsServed - demographicsServedDetails: ' + JSON.stringify(demographicsServedDetails));

                    // numFamiliesServed
                    if (demographicsServedDetails.numFamiliesServed > 0) {
                        component.set("v.numFamiliesServed", demographicsServedDetails.numFamiliesServed);
                    }

                    // demographicServedList
                    var demographicServedList = demographicsServedDetails.demographicServedList;

                    // load table with demographics
                    this.setDemographicsTableData(component, null, demographicServedList);
                    component.set("v.isUpdate", true); // indicates existing demographic values
                }
                else {
                    console.log("GearOrder_EnterBulkDemographicsHelper > getDemographicsServed - failed with state: " + state);
                }
            });

            // Send action off to be executed
            $A.enqueueAction(action);

        } // end doAction

    }, // end getDemographicsServed

   loadPicklistValues: function(component) {
        var componentAttribute;
        var objectName;
        var field;
        
        // gender options
        componentAttribute = 'raceEthnicityOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Child_Race_Ethnicity__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);  
        
    }, // end loadPicklistValues
    
    getPicklistValues: function(component, componentAttribute, objectName, field) {
        
        console.log('GearOrder_EnterBulkDemographicsHelper > getPicklistValues - componentAttribute: ' + componentAttribute + ', objectName: ' + objectName + ', field: ' + field);
        
        // Create the action
        var action = component.get("c.getPicklistValues"); // method on the GearOrderController
        action.setParams({
            "obj": {sobjectType : objectName},
            "field": field
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_EnterBulkDemographicsHelper > getPicklistValues response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                //console.log('GearOrder_EnterBulkDemographicsHelper > getPicklistValues - returnValue: ' + JSON.stringify(options));
            	component.set("v." + componentAttribute, options);
                
                // set table data
                this.setDemographicsTableData(component, options, null);
            }
            else {
                console.log("GearOrder_EnterBulkDemographicsHelper > getPicklistValues - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end getPicklistValues
    
     
    // DEMOGRAPHICS TABLE OPERATIONS
    
    setDemographicsTableData: function(component, raceEthnicityOptionList, demographicServedList) {
        console.log('GearOrder_EnterBulkDemographicsHelper > setDemographicsTableData raceEthnicityOptionList: ' + JSON.stringify(raceEthnicityOptionList)
            + ', demographicServedList: ' + JSON.stringify(demographicServedList));
        
        // demographic table data
        var data = Array();

        if (raceEthnicityOptionList) {
            for (var i = 0; i < raceEthnicityOptionList.length; ++i) {
                var item = raceEthnicityOptionList[i];
                var dataItem = {};
                dataItem.RaceEthnicity = item.label;
                dataItem.PercentFamiliesServed = 0;

                var isGearOrder = component.get("v.isGearOrder");
                if (isGearOrder) {
                    dataItem.NumFamiliesServed = 0;
                }

                data.push(dataItem);
            }
        } else if (demographicServedList) {
            var totalFamiliesServed = component.get("v.numFamiliesServed");
            var total_PercentFamiliesServed = 0;
            for (var i = 0; i < demographicServedList.length; ++i) {
                var item = demographicServedList[i];
                var dataItem = {};
                dataItem.RaceEthnicity = item.Race_Ethnicity__c;
                dataItem.PercentFamiliesServed = item.Percent_Served__c;
                total_PercentFamiliesServed += item.Percent_Served__c; // total percentages

                var isGearOrder = component.get("v.isGearOrder");
                if (isGearOrder) {
                    dataItem.NumFamiliesServed = this.calculateNumFamiliesServed(totalFamiliesServed, dataItem.PercentFamiliesServed);
                }

                data.push(dataItem);
            }
            component.set("v.total_PercentFamiliesServed", total_PercentFamiliesServed);
        }
        console.log('GearOrder_EnterBulkDemographicsHelper > setDemographicsTableData data: ' + JSON.stringify(data));  
        
        // set table data
        component.set('v.demographicsTableData', data);
                        
        // stop the spinner
        component.set('v.isLoading', false);
        
        // sort table by order item 'Race_Ethnicity'
        var fieldName = 'RaceEthnicity';
        var sortDirection = 'asc';
        this.updateColumnSorting(component, fieldName, sortDirection);
        
    }, // end setOrderItemsTableData  

    updateColumnSorting: function(component, fieldName, sortDirection) {
		component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        // Using var for 'this' because 'this.sortData' within the anonymous function isn't recognized
        // because 'this' inside the anonymous function is empty
        var helper = this; 
        setTimeout(function() {            
            console.log('GearOrder_EnterBulkDemographicsHelper > sort - fieldName: ' + fieldName + ', sortDirection: ' + sortDirection);
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }, 0);        
    }, // end updateColumnSorting
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.demographicsTableData");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.demographicsTableData", data);
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
    
    updateDemographicsTable: function(component, draftValues) {
        console.log('GearOrder_EnterBulkDemographicsHelper > updateDemographicsTable');
        
        var totalFamiliesServed = component.get('v.numFamiliesServed');
        console.log('GearOrder_EnterBulkDemographicsHelper > updateDemographicsTable - numFamiliesServed: ' + numFamiliesServed);
        
        var tableDataList = component.get('v.demographicsTableData');
        var totalPercentage = 0;
                
        for (var i = 0; i < tableDataList.length; ++i) {
            var data = tableDataList[i];
            //console.log('GearOrder_EnterBulkDemographicsHelper > updateDemographicsTable - data: ' + JSON.stringify(data)); 
            
            if (draftValues) { // draftValues will be null if this method was triggered by the update of Num_Families_Served
                for (var d = 0; d < draftValues.length; ++d) {
                    var draft = draftValues[d];
                    //console.log('GearOrder_EnterBulkDemographicsHelper > updateDemographicsTable - draft: ' + JSON.stringify(draft)); 
                    if (data.RaceEthnicity == draft.RaceEthnicity) {
                        // update table data w/ draft value
                        data.PercentFamiliesServed = draft.PercentFamiliesServed;
                        tableDataList[i] = data;
                    }
                }
            } // end if draftValues

            var isGearOrder = component.get("v.isGearOrder");
            if (isGearOrder) {
                // calculate numFamiliesServed based on percentage
                var numFamiliesServed = 0;
                if (data.PercentFamiliesServed > 0) {
                    numFamiliesServed = this.calculateNumFamiliesServed(totalFamiliesServed, data.PercentFamiliesServed);
                }
                console.log('numFamiliesServed: ' + numFamiliesServed + ', percent: ' + data.PercentFamiliesServed);
                data.NumFamiliesServed = numFamiliesServed;
            }
            
			// add totalPercentage
			totalPercentage += parseInt(data.PercentFamiliesServed, 10);
            
        } // end for tableDataList
        
        component.set('v.total_PercentFamiliesServed', totalPercentage);
        
        if (totalPercentage < 100) {
            // set error message and don't update table data
            component.set('v.errorMessage', 'Total % Families Served must equal 100');
        } else if (totalPercentage > 100) {
            // set error message and don't update table data
            component.set('v.errorMessage', 'Total % Families Served cannot be greater than 100');
        } else {
            // clear error message and update table data
            component.set('v.errorMessage', '');
            console.log('GearOrder_EnterBulkDemographicsHelper > updateDemographicsTable - updated tableData: ' + JSON.stringify(tableDataList)); 
        	component.set('v.demographicsTableData', tableDataList);
            component.find("demographicsTable").set("v.draftValues", null); // hides the 'Save' and 'Clear' buttons
        }
       
    }, // end updateDemographicsTable

    calculateNumFamiliesServed: function(totalFamiliesServed, percentFamiliesServed) {
        return Math.round(totalFamiliesServed * (percentFamiliesServed / 100));
    },

    createDemographics: function(component, orderID, totalNumFamiliesServed, demographicsTableData) {
        
        // demographicsTableData here is formatted as a List of objects that match the table data structure
        // so each entry in the list will look like {"RaceEthnicity":"African","PercentFamiliesServed":"100","NumFamiliesServed":10}
        // the demographicTableData is passed to the apex controller as a json string, where it is deserialized into a list of objects
        
        console.log('GearOrder_EnterBulkDemographicsHelper > createDemographics - for orderID: ' + orderID + ', totalNumFamiliesServed: ' + totalNumFamiliesServed + ', demographicsTableData: ' + JSON.stringify(demographicsTableData));        

        // Create the action
        var doAction = true;
        var action = component.get("c.createGearOrderDemographics"); // method on the GearOrderController
        if (orderID) {
            action.setParams({
                "orderID": orderID,
                "totalNumFamiliesServed": totalNumFamiliesServed, 
                "demographicList": JSON.stringify(demographicsTableData)
            });
        } else {
            // no input parameters to find Order
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_EnterBulkDemographicsHelper > createDemographics response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
               	// response                
                var responseList = response.getReturnValue();
            	console.log('GearOrder_EnterBulkDemographicsHelper > createDemographics responseList: ' + JSON.stringify(responseList));
                
                // display success message and close quick action modal
				component.set('v.demographicsCreated', true);              
            }
            else {
                console.log("GearOrder_EnterBulkDemographicsHelper > createDemographics - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end createDemographics        
    
});