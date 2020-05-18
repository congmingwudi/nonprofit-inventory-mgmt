({

    getGearOrderSiblingDemographics: function(component, demographicID) {
        
        // return
        var siblingsList = null; 
        
        // retrieve Gear Order Demographics
        console.log('GearOrder_SiblingDemographicsEditHelper > getGearOrderSiblingDemographics - demographicID: ' + demographicID);

		// isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);
        
        // Create the action
        var doAction = true;
        var action = component.get("c.getGearOrderSiblingDemographics"); // method on the GearOrderDemographicsController
        if (demographicID != '') {
            action.setParams({
                "demographicID": demographicID
            });
        } else {
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_SiblingDemographicsEditHelper > getGearOrderSiblingDemographics response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // siblingsList                
                siblingsList = response.getReturnValue();
            	console.log('GearOrder_SiblingDemographicsEditHelper > getGearOrderSiblingDemographics response - siblingsList: ' + JSON.stringify(siblingsList));                
                component.set("v.siblingsList", siblingsList);
                
                // set table data
                this.setSiblingDemographicsTableData(component, siblingsList);
            }
            else {
                console.log("GearOrder_SiblingDemographicsEditHelper > getGearOrderSiblingDemographics - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
        if (siblingsList == null) {
            siblingsList = new Array();
        }
        
        return siblingsList;
        
    }, // end getGearOrderSiblingDemographics 
    
    
    // SIBLING DEMOGRAPHICS TABLE OPERATIONS
    
    setSiblingDemographicsTableData: function(component, siblingsList) {
        console.log('GearOrder_SiblingDemographicsEditHelper > setSiblingDemographicsTableData - siblingsList: ' + siblingsList.length);  
        //console.log('GearOrder_SiblingDemographicsEditHelper > setSiblingDemographicsTableData - siblingsList: ' + JSON.stringify(demographicsList));          

        // sibling demographic data
        var data = Array();        
        for (var i = 0; i < siblingsList.length; ++i) {
            var item = siblingsList[i];            
            var dataItem = {};
            dataItem.Name = item.Name;
            dataItem.SiblingGender = item.Sibling_Gender__c;
            dataItem.SiblingAge = item.Sibling_Age__c;
            data.push(dataItem);           
        }
        //console.log('GearOrder_SiblingDemographicsEditHelper > setSiblingDemographicsTableData - data: ' + JSON.stringify(data));  
        
        // set table data
        component.set('v.tableData', data);
                        
        // stop the spinner
        component.set('v.isLoading', false);
        
        // sort table by order item 'Name'
        var fieldName = 'Name';
        var sortDirection = 'asc';
        var showLoadingSpinner = false;
        this.updateColumnSorting(component, fieldName, sortDirection, showLoadingSpinner);
        
    }, // end setSiblingDemographicsTableData  

    updateColumnSorting: function(component, fieldName, sortDirection, showLoadingSpinner) {
        if (showLoadingSpinner) component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        // Using var for 'this' because 'this.sortData' within the anonymous function isn't recognized
        // because 'this' inside the anonymous function is empty
        var helper = this; 
        setTimeout(function() {            
            console.log('GearOrder_SiblingDemographicsEditHelper > sort - fieldName: ' + fieldName + ', sortDirection: ' + sortDirection);
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
       
    
   // MODAL DIALOG OPERATIONS
    
   openSiblingModal_addSibling: function(component) {
        
        // init sibling demographic
        var sibling = {};
        sibling.Sibling_Gender__c = "Unknown";
        sibling.Sibling_Age__c = "Unknown";
        component.set("v.sibling", sibling);
        
        console.log('GearOrder_SiblingDemographicsEditHelper > openSiblingModal_addSibling - new sibling demographic: ' + JSON.stringify(sibling));
        
        // open modal 
        component.set('v.sibling_modalAction', 'create');
        component.set('v.sibling_modalTitle', 'Add Sibling Demographic');
        component.set('v.sibling_readonly', false);
    	component.set("v.isSiblingOpen", true);
        
   	}, // end openSiblingModal_addSibling 
         
    createGearOrderSiblingDemographic: function(component, sibling) {
        
        console.log('GearOrder_SiblingDemographicsEditHelper > createGearOrderSiblingDemographic - ' + JSON.stringify(sibling));
        
        var demographicID = sibling.Gear_Order_Demographic__c;
        
        // Create the action
        var action = component.get("c.createGearOrderSiblingDemographic"); // method on the GearOrderDemographicsController
        action.setParams({
            "demographicID": demographicID,
            "siblingGender": sibling.Sibling_Gender__c,
            "siblingAge": sibling.Sibling_Age__c       
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_SiblingDemographicsEditHelper > createGearOrderSiblingDemographic - response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var sibling = response.getReturnValue();
                console.log('GearOrder_SiblingDemographicsEditHelper > createGearOrderSiblingDemographic - sibling demographic created: ' + JSON.stringify(sibling));
                
                // refresh sibling demographics
                this.getGearOrderSiblingDemographics(component, demographicID);
            }
            else {
                console.log("GearOrder_SiblingDemographicsEditHelper > createGearOrderSiblingDemographic - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end createGearOrderSiblingDemographic

    updateGearOrderSiblingDemographic: function(component, sibling) {
        
        console.log('GearOrder_SiblingDemographicsEditHelper > updateGearOrderSiblingDemographic - ' + JSON.stringify(sibling));
        
        var demographicID = sibling.Gear_Order_Demographic__c;
        
        // Create the action
        var action = component.get("c.updateGearOrderSiblingDemographic"); // method on the GearOrderDemographicsController
        action.setParams({
            "siblingDemographicID": sibling.Id,
            "siblingGender": sibling.Sibling_Gender__c,
            "siblingAge": sibling.Sibling_Age__c       
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_SiblingDemographicsEditHelper > updateGearOrderSiblingDemographic - response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var sibling = response.getReturnValue();
                console.log('GearOrder_SiblingDemographicsEditHelper > updateGearOrderSiblingDemographic - sibling demographic updated: ' + JSON.stringify(sibling));
                
                // refresh sibling demographics
                this.getGearOrderSiblingDemographics(component, demographicID);
            }
            else {
                console.log("GearOrder_SiblingDemographicsEditHelper > updateGearOrderSiblingDemographic - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end updateGearOrderSiblingDemographic    

    deleteGearOrderSiblingDemographic: function(component, sibling) {
        
        console.log('GearOrder_SiblingDemographicsEditHelper > deleteGearOrderSiblingDemographic: ' + JSON.stringify(sibling));
        
        var demographicID = sibling.Gear_Order_Demographic__c;
        
        // Create the action
        var action = component.get("c.deleteGearOrderSiblingDemographic"); // method on the GearOrderDemographicsController
        action.setParams({
            "siblingDemographicID": sibling.Id,
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_SiblingDemographicsEditHelper > deleteGearOrderSiblingDemographic - response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var sibling = response.getReturnValue();
                console.log('GearOrder_SiblingDemographicsEditHelper > deleteGearOrderSiblingDemographic - sibling demographic deleted: ' + JSON.stringify(sibling));
                
                // refresh sibling demographics
                this.getGearOrderSiblingDemographics(component, demographicID);
            }
            else {
                console.log("GearOrder_SiblingDemographicsEditHelper > deleteGearOrderSiblingDemographic - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end deleteGearOrderSiblingDemographic
    
    setSiblingDemographicFields: function(component, row) {
        console.log('GearOrder_SiblingDemographicsEditHelper > setSiblingDemographicFields - row: ' + JSON.stringify(row));
        
        // get sibling demographic
        var sibling;
        var siblingsList = component.get("v.siblingsList");
        console.log('GearOrder_SiblingDemographicsEditHelper > siblingsList: ' + JSON.stringify(siblingsList));
        for (var i = 0; i < siblingsList.length; ++i) {
            var item = siblingsList[i];
            if (item.Name == row.Name) {
                sibling = item;
                sibling.Gear_Order_Demographic__c = component.get("v.demographic.Id");
            }
        }
        console.log('GearOrder_SiblingDemographicsEditHelper > sibling demographic: ' + JSON.stringify(sibling));
                
        // update sibling demographic attribute
        component.set("v.sibling", sibling);

    }, // setSiblingDemographicFields
        
    loadPicklistValues: function(component) {
        var componentAttribute;
        var objectName;
        var field;
        
        // child age options
        componentAttribute = 'sibling_ageOptionList';
        objectName = 'Gear_Order_Sibling_Demographic__c';
        field = 'Sibling_Age__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);  
        
        // child gender options
        componentAttribute = 'sibling_genderOptionList';
        objectName = 'Gear_Order_Sibling_Demographic__c';
        field = 'Sibling_Gender__c';
        this.getPicklistValues(component, componentAttribute, objectName, field);
        
    }, // end loadPicklistValues
    
    getPicklistValues: function(component, componentAttribute, objectName, field) {
        
        console.log('GearOrder_SiblingDemographicsEditHelper > getPicklistValues - componentAttribute: ' + componentAttribute + ', objectName: ' + objectName + ', field: ' + field);
        
        // Create the action
        var action = component.get("c.getPicklistValues"); // method on the GearOrderController
        action.setParams({
            "obj": {sobjectType : objectName},
            "field": field
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_SiblingDemographicsEditHelper > getPicklistValues response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                console.log('GearOrder_SiblingDemographicsEditHelper > getPicklistValues - returnValue: ' + JSON.stringify(options));
            	component.set("v." + componentAttribute, options);
            }
            else {
                console.log("GearOrder_SiblingDemographicsEditHelper > getPicklistValues - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end getPicklistValues	     

    
});