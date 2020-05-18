({
    init: function(component, event, helper) {
        console.log('GearOrder_SiblingDemographicsEditController > init');
		
        var demographic = component.get('v.demographic');
        console.log('GearOrder_SiblingDemographicsEditController > init - demographic: ' + JSON.stringify(demographic));
        if (demographic == null) {
			demographic = {};
            demographic.Id = "a0vK0000009ID2YIAW";
            demographic.Name = "GOD-0000000245";
            demographic.Child_Alias__c = "Child 1";
            demographic.Child_Gender__c = "Unknown";
            demographic.Child_Age__c = "Unknown";
            demographic.Child_Race_Ethnicity__c = "Other/Unknown";        	
        }
        console.log('GearOrder_SiblingDemographicsEditController > init - demographic: ' + JSON.stringify(demographic));
        var demographicLabel = demographic.Child_Alias__c + ' | Gender: ' + demographic.Child_Gender__c + ' | Age: ' + demographic.Child_Age__c + ' | Ethnicity: ' + demographic.Child_Race_Ethnicity__c;        
		component.set('v.demographicLabel', demographicLabel);

        // SIBLINGS TABLE columns
    	component.set('v.tableColumns', [
            {label: 'Sibling ID', fieldName: 'Name', type: 'text', sortable: true, iconName: "standard:lead_list"},
            {label: 'Gender', fieldName: 'SiblingGender', type: 'text', sortable: true, iconName: "custom:custom7", cellAttributes: { alignment: 'left' } },
            {label: 'Age', fieldName: 'SiblingAge', type: 'text', sortable: true, iconName: "standard:topic2", cellAttributes: { alignment: 'left' } },
            {type:  'button', typeAttributes: {iconName: 'utility:edit', label: '', name: 'edit', disabled: false}, cellAttributes: { alignment: 'center' } },
            {type:  'button', typeAttributes: {iconName: 'utility:delete', label: '', name: 'delete', disabled: false}, cellAttributes: { alignment: 'center' } },
        ]);
            
        // load picklist values
        helper.loadPicklistValues(component);
            
        // load sibling demographics
        var demographicID = demographic.Id;
		helper.getGearOrderSiblingDemographics(component, demographicID);            
        
    }, // end init
    
    closeModal: function (component, event, helper) {
        console.log('GearOrder_SiblingDemographicsEditController > closeModal');
        component.set('v.isOpen', false);       
    }, // end closeModal
                               

    // SIBLING DEMOGRAPHICS TABLE OPERATIONS
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var showLoadingSpinner = true;
        helper.updateColumnSorting(component, fieldName, sortDirection, showLoadingSpinner);
    }, // end updateColumnSorting
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('GearOrder_SiblingDemographicsEditController > row action: ' + JSON.stringify(action));

        switch (action.name) {
            case 'edit': {
            	console.log('GearOrder_SiblingDemographicsEditController > edit sibling demographic: ' + JSON.stringify(row));                
                helper.setSiblingDemographicFields(component, row);
                
                // open modal
                component.set('v.sibling_modalAction', 'update');
                component.set('v.sibling_modalTitle', 'EDIT SIBLING DEMOGRAPHIC');
            	component.set('v.sibling_readonly', false);
    			component.set("v.isSiblingOpen", true);
                break;
            }
            case 'delete': {
            	console.log('GearOrder_SiblingDemographicsEditController > delete sibling demographic: ' + JSON.stringify(row));                
                helper.setSiblingDemographicFields(component, row);              
                               
                // open modal
                component.set('v.sibling_modalAction', 'delete');
                component.set('v.sibling_modalTitle', 'DELETE SIBLING DEMOGRAPHIC');
            	component.set('v.sibling_readonly', true);
    			component.set("v.isSiblingOpen", true);
                break;
        	}
        } // end switch
    }, // end handleRowAction
            
    isLoadingChanged: function(component, event, helper) {        
        var isLoading = event.getParam("value");
        console.log('GearOrder_SiblingDemographicsEditController > isLoadingChanged: ' + isLoading); 
        
        if (!isLoading) {  
            // handle reopen Add Sibling modal
            var sibling_modalReopen = component.get("v.sibling_modalReopen");
            if (sibling_modalReopen) {
                helper.openSiblingModal_addSibling(component);
                component.set("v.sibling_modalReopen", false); // reset to false
            }
        }
   	}, // end isLoadingChanged 
    
            
    // SIBLING DETAIL MODAL OPERATIONS  
      
    openSiblingModal_addSibling: function(component, event, helper) {  
        console.log('GearOrder_SiblingDemographicsEditController > openSiblingModal_addSibling');
        helper.openSiblingModal_addSibling(component);
   	}, // end openSiblingModal_addSibling
    
    closeSiblingModal: function(component, event, helper) {
        component.set("v.isSiblingOpen", false);
    }, // end closeSiblingModal  
    
    saveSiblingDemographic: function(component, event, helper) {
        var modalAction = component.get('v.sibling_modalAction');
        var demographicID = component.get("v.demographic.Id");
        var buttonClicked = event.getSource().getLocalId();  
        console.log('GearOrder_SiblingDemographicsEditController > saveSiblingDemographic (' + modalAction + ' / ' + buttonClicked + ') - for demographicID: ' + demographicID);
        
        // sibling demographic
        var sibling = component.get("v.sibling");
        sibling.Gear_Order_Demographic__c = demographicID;
            
        // isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);

        // store sibling demographic
        console.log('GearOrder_SiblingDemographicsEditController > saveSiblingDemographic (' + modalAction + ') - sibling demographic: ' + JSON.stringify(sibling));
        if (modalAction == 'create') {
        	helper.createGearOrderSiblingDemographic(component, sibling);
        } else if (modalAction == 'update') {
        	helper.updateGearOrderSiblingDemographic(component, sibling);
        } 
        
        if (buttonClicked == "button_saveAddAnotherSibling") {
            // use attributes isLoading and sibling_modalReopen to control the reopening of the modal.
            // when isLoading is set back to false after processing of helper.createGearOrderSiblingDemographic
            // then isLoading is set to false, and it's onchange controller function will reopen the modal
            // if sibling_modalReopen is true            
            component.set("v.sibling_modalReopen", true);
        }
            
        // close modal
        component.set("v.isSiblingOpen", false); 
 		
    }, // end saveSiblingDemographic

    deleteSiblingDemographic: function(component, event, helper) {
        var modalAction = component.get('v.sibling_modalAction');
        var orderID = component.get("v.orderID");        
        var sibling = component.get("v.sibling");
        sibling.Gear_Order__c = orderID;
        console.log('GearOrder_SiblingDemographicsEditController > deleteSiblingDemographic (' + modalAction + ') - for sibling demographic: ' + JSON.stringify(sibling));

        // isLoading controls the spinner to indicate processing
        component.set('v.isLoading', true);
            
        helper.deleteGearOrderSiblingDemographic(component, sibling);
        
		// close modal
        component.set("v.isSiblingOpen", false);
 
    }, // end deleteSiblingDemographic  

            
            
})