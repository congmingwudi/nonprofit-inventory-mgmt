({

    getGearOrder: function(component, orderID, orderName) {
        
        console.log('GearOrder_DemographicsEditHelper > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);        
        
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
            console.log('GearOrder_DemographicsEditHelper > getGearOrder response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var orderList = response.getReturnValue();
            	//console.log('GearOrder_DemographicsEditHelper > getGearOrder - orderList: ' + JSON.stringify(orderList));
                
                if (orderList.length > 0) {
                    // set order
                    var order = orderList[0];
                    console.log('GearOrder_DemographicsEditHelper > getGearOrder - order: ' + JSON.stringify(order));
                    component.set("v.order", order);
                    component.set("v.orderID", order.Id);
                    component.set("v.orderName", order.Name);
                    
                    this.getGearOrderDemographics(component, order.Id);
                }
                
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > getGearOrder - failed with state: " + state);
            }
        }); // end callback

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end getGearOrder  

    getGearOrderDemographics: function(component, orderID) {

       console.log('GearOrder_DemographicsEditHelper > getGearOrderDemographics - orderID: ' + orderID);
        
        // return
        var demographicsList = null; 
                 
        // Create the action
        var doAction = true;
        var action = component.get("c.getGearOrderDemographics"); // method on the GearOrderDemographicsController
        if (orderID != '') {
            action.setParams({
                "orderID": orderID
            });
        } else {
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > getGearOrderDemographics response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // set demographicsList                
                demographicsList = response.getReturnValue();
            	//console.log('GearOrder_DemographicsEditHelper > getGearOrderDemographics response - demographicsList: ' + JSON.stringify(demographicsList));                
                component.set("v.demographicsList", demographicsList);
                
                // set table data
                this.setDemographicsTableData(component, demographicsList);
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > getGearOrderDemographics - failed with state: " + state);
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
        
    }, // end getGearOrderDemographics
    
    saveNumFamiliesServed: function(component, orderID, numFamiliesServed) {
        
        console.log('GearOrder_DemographicsEditHelper > saveNumFamiliesServed - orderID: ' + orderID + ', numFamiliesServed: ' + numFamiliesServed);        
        
        // Create the action
        var doAction = true;
        var action = component.get("c.updateNumFamiliesServed"); // method on the GearOrderDemographicsController
        if ((orderID != '') && (numFamiliesServed != '')) {
            action.setParams({
                "orderID": orderID,
                "numFamiliesServed": numFamiliesServed
            });        
        } else {
            // required input parameters missing
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > saveNumFamiliesServed response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {                
               	// responseStatus                
                var responseStatus = response.getReturnValue();
            	console.log('GearOrder_DemographicsEditHelper > saveNumFamiliesServed responseStatus: ' + JSON.stringify(responseStatus));           
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > saveNumFamiliesServed - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end saveNumFamiliesServed      
    
    
    // DEMOGRAPHICS TABLE OPERATIONS
    
    setDemographicsTableData: function(component, demographicsList) {
        
        console.log('GearOrder_DemographicsEditHelper > setDemographicsTableData demographicsList: ' + demographicsList.length);  
        //console.log('GearOrder_DemographicsEditHelper > setDemographicsTableData demographicsList: ' + JSON.stringify(demographicsList));          

        // subset of demographic data
        var data = Array();        
        for (var i = 0; i < demographicsList.length; ++i) {
            var item = demographicsList[i];            
            var dataItem = {};
            dataItem.Name = item.Name;
            dataItem.ChildAlias = item.Child_Alias__c;
            dataItem.ChildGender = item.Child_Gender__c;
            dataItem.ChildAge = item.Child_Age__c;
            dataItem.ChildRaceEthnicity = item.Child_Race_Ethnicity__c;
            data.push(dataItem);           
        }
        //console.log('GearOrder_DemographicsEditHelper > setDemographicsTableData data: ' + JSON.stringify(data));  
        
        // set table data
        component.set('v.tableData', data);
                        
        // stop the spinner
        component.set('v.isLoading', false);
        
        // sort table by order item 'Name'
        var fieldName = 'Name';
        var sortDirection = 'asc';
        var showLoadingSpinner = false;
        this.updateColumnSorting(component, fieldName, sortDirection, showLoadingSpinner);
        
    }, // end setOrderItemsTableData  

    updateColumnSorting: function(component, fieldName, sortDirection, showLoadingSpinner) {
        if (showLoadingSpinner) component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        // Using var for 'this' because 'this.sortData' within the anonymous function isn't recognized
        // because 'this' inside the anonymous function is empty
        var helper = this; 
        setTimeout(function() {            
            console.log('GearOrder_DemographicsEditHelper > sort - fieldName: ' + fieldName + ', sortDirection: ' + sortDirection);
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            if (showLoadingSpinner) component.set('v.isLoading', false);
        }, 0);        
    }, // end updateColumnSorting
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.tableData");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.tableData", data);
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
    
    updateDemographicInlineEdits: function(component, draftValues) {
        var orderID = component.get("v.orderID");
        console.log('GearOrder_DemographicsEditHelper > updateDemographicInlineEdits - orderID: ' + orderID + ', draftValues: ' + JSON.stringify(draftValues));

        // isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);        
        
        // draftValues here is formatted as a List of objects that match the table data structure, only the id field and editable fields
        // like this: [{"ChildAlias":"Bob","Name":"GOD-0000000245"}]
        // the draftValues is passed to the apex controller as a json string, where it is deserialized into a list of objects
        
        // Create the action
        var doAction = true;
        var action = component.get("c.updateDemographics"); // method on the GearOrderDemographicsController
        if (orderID) {
            action.setParams({
                "orderID": orderID,
                "demographicList": JSON.stringify(draftValues)
            });
        } else {
            // no input parameters to find Order
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > updateDemographicInlineEdits response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
               	// response                
                var responseList = response.getReturnValue();
            	console.log('GearOrder_DemographicsEditHelper > updateDemographicInlineEdits responseList: ' + JSON.stringify(responseList));
                
                // get updated demographics 
				this.getGearOrderDemographics(component, orderID);				              
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > updateDemographicInlineEdits - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
        // hide the 'Save' and 'Clear' buttons
        component.find("demographicsTable").set("v.draftValues", null); 
       
    }, // end updateDemographicInlineEdits
    
    // MODAL DIALOG OPERATIONS
    
    openModal_AddDemographic: function(component) {
        
        // init demographic
        var demographic = {};
        this.setDefaultChildAlias(component, demographic);    
        demographic.Child_Race_Ethnicity__c = "Other/Unknown";
        demographic.Parent_Race_Ethnicity__c = "Other/Unknown";
        demographic.Parent_Marital_Status__c = "Unknown";
        component.set("v.demographic", demographic);      
        
        console.log('GearOrder_DemographicsEditHelper > openModal_AddDemographic - new demographic: ' + JSON.stringify(demographic));
        
        // open modal 
        component.set('v.demographic_modalAction', 'create');
        component.set('v.demographic_modalTitle', 'ADD ORDER DEMOGRAPHIC');
        component.set('v.demographic_readonly', false);
    	component.set("v.isOpen", true);
        
   	}, // end openModal_AddDemographic
         
    createGearOrderDemographic: function(component, demographic) {
        
        console.log('GearOrder_DemographicsEditHelper > createGearOrderDemographic - ' + JSON.stringify(demographic));
        
        // Create the action
        var action = component.get("c.createGearOrderDemographic"); // method on the GearOrderDemographicsController
        action.setParams({
            "orderID": demographic.Gear_Order__c,
            "childAlias": demographic.Child_Alias__c,
            "childGender": demographic.Child_Gender__c,
            "childAge": demographic.Child_Age__c,
            "childRaceEthnicity": demographic.Child_Race_Ethnicity__c,
            "parentGender": demographic.Parent_Gender__c,
            "parentAge": demographic.Parent_Age__c,
            "parentRaceEthnicity": demographic.Parent_Race_Ethnicity__c,
            "parentMaritalStatus": demographic.Parent_Marital_Status__c,
            "comment": demographic.Comment__c            
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > createGearOrderDemographic response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var demographic = response.getReturnValue();
                var orderID = demographic.Gear_Order__c;
                console.log('GearOrder_DemographicsEditHelper > createGearOrderDemographic - demographic created: ' + JSON.stringify(demographic));
                
                // refresh gear order to show updated list of demographics
                this.getGearOrder(component, orderID);
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > createGearOrderDemographic - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end createGearOrderDemographic

    updateGearOrderDemographic: function(component, demographic) {
        
        console.log('GearOrder_DemographicsEditHelper > updateGearOrderDemographic - ' + JSON.stringify(demographic));
        
        // Create the action
        var action = component.get("c.updateGearOrderDemographic"); // method on the GearOrderDemographicsController
        action.setParams({
            "orderID": demographic.Gear_Order__c, // only passed in so that it will be returned with the demographic
            "demographicID": demographic.Id,
            "childAlias": demographic.Child_Alias__c,
            "childGender": demographic.Child_Gender__c,
            "childAge": demographic.Child_Age__c,
            "childRaceEthnicity": demographic.Child_Race_Ethnicity__c,
            "parentGender": demographic.Parent_Gender__c,
            "parentAge": demographic.Parent_Age__c,
            "parentRaceEthnicity": demographic.Parent_Race_Ethnicity__c,
            "parentMaritalStatus": demographic.Parent_Marital_Status__c,
            "comment": demographic.Comment__c  
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > updateGearOrderDemographic response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var demographic = response.getReturnValue();
                var orderID = demographic.Gear_Order__c;
                //console.log('GearOrder_DemographicsEditHelper > updateGearOrderDemographic - demographic updated: ' + JSON.stringify(demographic));
                
                // refresh gear order to show updated list of demographics
                this.getGearOrder(component, orderID);
                
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > updateGearOrderDemographic - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end updateGearOrderDemographic    

    deleteGearOrderDemographic: function(component, demographic) {
        
        console.log('GearOrder_DemographicsEditHelper > deleteGearOrderDemographic - ' + JSON.stringify(demographic));
        
        // Create the action
        var action = component.get("c.deleteGearOrderDemographic"); // method on the GearOrderDemographicsController
        action.setParams({
            "orderID": demographic.Gear_Order__c, // only passed in so that it will be returned with the orderItem
            "demographicID": demographic.Id
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > deleteGearOrderDemographic response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var demographic = response.getReturnValue();
                var orderID = demographic.Gear_Order__c;
                console.log('GearOrder_DemographicsEditHelper > deleteGearOrderDemographic - demographic deleted: ' + JSON.stringify(demographic));
                
                // refresh gear order to show updated list of demographics
                this.getGearOrder(component, orderID);
                
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > deleteGearOrderDemographic - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end deleteGearOrderDemographic
    
    setDemographicFields: function(component, row) {
        
        console.log('GearOrder_DemographicsEditHelper > setDemographicFields - row: ' + JSON.stringify(row));
        
        // get demographic
        var demographic;
        var demographicsList = component.get("v.demographicsList");
        //console.log('GearOrder_DemographicsEditHelper > setDemographicFields - demographicsList: ' + JSON.stringify(demographicsList));
        for (var i = 0; i < demographicsList.length; ++i) {
            var item = demographicsList[i];
            if (item.Name == row.Name) {
                demographic = item;
            }
        }
        console.log('GearOrder_DemographicsEditHelper > setDemographicFields - demographic: ' + JSON.stringify(demographic));
                
        // update demographic attribute
        component.set("v.demographic", demographic);

    }, // setDemographicFields
        
    loadPicklistValues: function(component) {
        var componentAttribute;
        var objectName;
        var field;
        
        // child age options
        componentAttribute = 'demographic_childAgeOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Child_Age__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);  
        
        // child gender options
        componentAttribute = 'demographic_childGenderOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Child_Gender__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
        // child race/ethnicity options
        componentAttribute = 'demographic_childRaceEthnicityOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Child_Race_Ethnicity__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
        // parent age options
        componentAttribute = 'demographic_parentAgeOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Parent_Age__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
        // parent gender options
        componentAttribute = 'demographic_parentGenderOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Parent_Gender__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
        // parent marital status options
        componentAttribute = 'demographic_parentMaritalStatusOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Parent_Marital_Status__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
        // parent race/ethnicity options
        componentAttribute = 'demographic_parentRaceEthnicityOptionList';
        objectName = 'Gear_Order_Demographic__c';
        field = 'Parent_Race_Ethnicity__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
    }, // end loadPicklistValues
    
    getPicklistValues: function(component, componentAttribute, objectName, field) {
        
        console.log('GearOrder_DemographicsEditHelper > getPicklistValues - componentAttribute: ' + componentAttribute + ', objectName: ' + objectName + ', field: ' + field);
        
        // Create the action
        var action = component.get("c.getPicklistValues"); // method on the GearOrderController
        action.setParams({
            "obj": {sobjectType : objectName},
            "field": field
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_DemographicsEditHelper > getPicklistValues response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                console.log('GearOrder_DemographicsEditHelper > getPicklistValues - returnValue: ' + JSON.stringify(options));
            	component.set("v." + componentAttribute, options);
            }
            else {
                console.log("GearOrder_DemographicsEditHelper > getPicklistValues - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end getPicklistValues	 
    
    setDefaultChildAlias: function(component, demographic) {
        
        // default child alias to "Child 1", "Child 2"... 
        if(!demographic.Child_Alias__c || (demographic.Child_Alias__c == '')) {
        	var demographicsList = component.get("v.demographicsList");
            var childNum = demographicsList.length + 1;
            demographic.Child_Alias__c = "Child " + childNum;
        }    
            
    }, // end getDefaultChildAlias  
    
    validateFields: function (component) {
        
        var allGood = false;
        var errorMessage = "";

        // check that at least one demographic was entered
        var demographicsList = component.get("v.demographicsList");
        console.log("GearOrder_DemographicsEditHelper > validateFields - demographics length: " + demographicsList.length);
        if (demographicsList.length > 0) {
        	allGood = true;            
        } else {
          	allGood = false;
        	errorMessage = "Please enter at least one demographic to continue. ";
        }
        
        // check that # families served is greater than zero (1 or more)
        // and not greater than number of demographics
        var numFamiliesServed = component.get("v.order.Num_Families_Served__c");
        console.log("GearOrder_DemographicsEditHelper > validateFields - numFamiliesServed: " + numFamiliesServed);
        if (numFamiliesServed < 1) {
            allGood = false;
            errorMessage += "# of Families To Be Served must be at least 1. ";
        }
        if (numFamiliesServed > demographicsList.length) {
            allGood = false;
            errorMessage += "'# of Families To Be Served' cannot be more than the number of child demographics entered. ";
        }
        
        // set error message
        component.set("v.errorMessage", errorMessage);
        
		return allGood;
        
	}, // end validateFields 
       
});