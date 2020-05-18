({
    init: function(component, event, helper) {
        console.log('GearOrder_DemographicsEditController > init');        
		
        // DEMOGRAPHICS TABLE columns
    	component.set('v.tableColumns', [
            {label: 'Child ID', fieldName: 'Name', type: 'text', sortable: true, iconName: "standard:lead_list"},
            {label: 'Alias', fieldName: 'ChildAlias', type: 'text', sortable: true, iconName: "standard:individual", cellAttributes: { alignment: 'left' }, editable: true},
            {label: 'Gender', fieldName: 'ChildGender', type: 'text', sortable: true, iconName: "custom:custom7", cellAttributes: { alignment: 'left' } },
            {label: 'Age', fieldName: 'ChildAge', type: 'text', sortable: true, iconName: "standard:topic2", cellAttributes: { alignment: 'left' } },
            {label: 'Ethnicity', fieldName: 'ChildRaceEthnicity', type: 'text', sortable: true, iconName: "standard:groups", cellAttributes: { alignment: 'left' } },
            {type:  'button', typeAttributes: {iconName: 'utility:edit', label: '', name: 'edit', disabled: false}, cellAttributes: { alignment: 'center' } },
            /* Siblings removed. all handling of sibling demographics still in this component. To support capturing siblings again, just uncomment this line.
             *  {type:  'button', typeAttributes: {label: 'Siblings', name: 'edit_siblings', disabled: false}, cellAttributes: { alignment: 'center' } },
             */
            {type:  'button', typeAttributes: {iconName: 'utility:delete', label: '', name: 'delete', disabled: false}, cellAttributes: { alignment: 'center' } },
            ]);
        
        // load Gear Order (this pulls in order demographics)
        var orderID = component.get("v.orderID");
        var orderName = component.get("v.orderName");
		helper.getGearOrder(component, orderID, orderName);
        
        // load picklist values
        helper.loadPicklistValues(component);
        
    }, // end init
            
	handleNavigation : function(component, event, helper) {

        var allGood;

        // set 'navigation' attribute that the flow will use to determine flow path
        var buttonClicked = event.getSource().getLocalId();
        component.set('v.navigation', buttonClicked);
        console.log('GearOrder_DemographicsEditController > handleNavigation - clicked: ' + buttonClicked);

        if (buttonClicked == "nav_enterOrderItems") {
            // do field validation
            allGood = helper.validateFields(component);
            console.log('GearOrder_DemographicsEditController > handleNavigation - allGood: ' + allGood);
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
            
    saveNumFamiliesServed: function (component, event, helper) {
        var orderID = component.get('v.orderID');
        var numFamiliesServed = component.get('v.order.Num_Families_Served__c');
        console.log('GearOrder_DemographicsEditController > saveNumFamiliesServed - orderID: ' + orderID + ', numFamiliesServed: ' + numFamiliesServed);         
        helper.saveNumFamiliesServed(component, orderID, numFamiliesServed) ;   
    }, // end saveNumFamiliesServed

            
    // DEMOGRAPHICS TABLE OPERATIONS
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var showLoadingSpinner = true;
        helper.updateColumnSorting(component, fieldName, sortDirection, showLoadingSpinner);
    }, // end updateColumnSorting
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('GearOrder_DemographicsEditController > row action: ' + JSON.stringify(action));

        switch (action.name) {
            case 'edit': {
            	console.log('GearOrder_DemographicsEditController > edit order demographic: ' + JSON.stringify(row));                
                helper.setDemographicFields(component, row);
                
                // open modal
                component.set('v.demographic_modalAction', 'update');
                component.set('v.demographic_modalTitle', 'EDIT ORDER DEMOGRAPHIC');
            	component.set('v.demographic_readonly', false);
    			component.set("v.isOpen", true);
                break;
            }
            case 'edit_siblings': {
            	console.log('GearOrder_DemographicsEditController > edit siblings for order demographic: ' + JSON.stringify(row));                               
                helper.setDemographicFields(component, row); // sets 'v.demographic' that is passed to the siblings modal
            
                // open siblings modal
                component.set('v.siblings_modalTitle', 'EDIT SIBLING DEMOGRAPHICS');
    			component.set("v.siblings_isOpen", true);
                break;
            }
            case 'delete': {
            	console.log('GearOrder_DemographicsEditController > delete order item: ' + JSON.stringify(row));                
                helper.setDemographicFields(component, row);              
                               
                // open modal
                component.set('v.demographic_modalAction', 'delete');
                component.set('v.demographic_modalTitle', 'DELETE ORDER DEMOGRAPHIC');
            	component.set('v.demographic_readonly', true);
    			component.set("v.isOpen", true);
                break;
        	}
        } // end switch
    }, // end handleRowAction

    handleSave: function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log('GearOrder_DemographicsEditController > handleSave - draftValues: ' + JSON.stringify(draftValues));         
        helper.updateDemographicInlineEdits(component, draftValues); // save inline edit updates        
    }, // end handleSave
            
    isLoadingChanged: function(component, event, helper) {        
        var isLoading = event.getParam("value");
        console.log('GearOrder_DemographicsEditController > isLoadingChanged: ' + isLoading); 
        
        if (!isLoading) {  
            // handle reopen Add Demographic modal
            var demographic_modalReopen = component.get("v.demographic_modalReopen");
            if (demographic_modalReopen) {
                helper.openModal_AddDemographic(component);
                component.set("v.demographic_modalReopen", false); // reset to false
            }
        }
   	}, // end isLoadingChanged 
    
    // MODAL OPERATIONS  
      
    openModal_AddDemographic: function(component, event, helper) {        
        helper.openModal_AddDemographic(component);
   	}, // end openModal_AddDemographic
    
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    }, // end closeModal  
    
    saveDemographic: function(component, event, helper) {
        var modalAction = component.get('v.demographic_modalAction');
        var orderID = component.get("v.orderID");
        var buttonClicked = event.getSource().getLocalId();  
        console.log('GearOrder_DemographicsEditController > saveDemographic (' + modalAction + ' / ' + buttonClicked + ') - for orderID: ' + orderID);
        
        // demographic
        var demographic = component.get("v.demographic");
        demographic.Gear_Order__c = orderID;
		helper.setDefaultChildAlias(component, demographic);

        // store demographic
        console.log('GearOrder_DemographicsEditController > saveDemographic (' + modalAction + ') - demographic: ' + JSON.stringify(demographic));
        if (modalAction == 'create') {
        	helper.createGearOrderDemographic(component, demographic);
        } else if (modalAction == 'update') {
        	helper.updateGearOrderDemographic(component, demographic);
        } 
        
        if (buttonClicked == "button_saveAddAnotherDemographic") {
            // use attributes isLoading and demographic_modalReopen to control the reopening of the modal.
            // when isLoading is set back to false after processing of helper.createGearOrderDemographic
            // then isLoading is set to false, and it's onchange controller function will reopen the modal
            // if demographic_modalReopen is true            
            component.set("v.demographic_modalReopen", true);
        }
            
        // close modal
        component.set("v.isOpen", false); 
 		
    }, // end saveDemographic

    deleteDemographic: function(component, event, helper) {
        var modalAction = component.get('v.demographic_modalAction');
        var orderID = component.get("v.orderID");        
        var demographic = component.get("v.demographic");
        demographic.Gear_Order__c = orderID;
        console.log('GearOrder_DemographicsEditController > deleteDemographic (' + modalAction + ') - for demographic: ' + JSON.stringify(demographic));
        
        helper.deleteGearOrderDemographic(component, demographic);
        
		// close modal
        component.set("v.isOpen", false);
 
    }, // end deleteDemographic      
    
})