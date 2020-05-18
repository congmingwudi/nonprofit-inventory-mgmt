({
    init: function(component, event, helper) {
        console.log('GearOrder_EnterBulkDemographicsController > init');

        var isAccount = component.get("v.isAccount");
        if (isAccount) {
            console.log('GearOrder_EnterBulkDemographicsController > init - Account record');

            // accountID
            var recordId = component.get("v.recordId");
            component.set("v.accountID", recordId);

            // get demographics served for the account
            helper.getDemographicsServed(component);

            // numFamiliesServedLabel
            component.set("v.numFamiliesServedLabel", "Estimated number of children that will utilize baby gear provided by WeeCycle per year?");

            // tableHeight
            component.set("v.tableHeight", "345px");

            // set table columns
            component.set('v.tableColumns', [
                {label: 'Race / Ethnicity', fieldName: 'RaceEthnicity', type: 'text', sortable: false, editable: false},
                {label: '% Children Served', fieldName: 'PercentFamiliesServed', type: 'number', sortable: false, editable: true, cellAttributes: { alignment: "left"} }
            ]);

        } else {
            console.log('GearOrder_EnterBulkDemographicsController > init - Gear_Order__c record');
            component.set("v.isGearOrder", true);

            // numFamiliesServedLabel
            component.set("v.numFamiliesServedLabel", "# Children Served");

            // tableHeight
            component.set("v.tableHeight", "290px");

            // set table columns
            component.set('v.tableColumns', [
                {label: 'Race / Ethnicity', fieldName: 'RaceEthnicity', type: 'text', sortable: false, editable: false},
                {label: '% Children Served', fieldName: 'PercentFamiliesServed', type: 'number', sortable: false, editable: true, cellAttributes: { alignment: "left"} },
                {label: '# Children Served', fieldName: 'NumFamiliesServed', type: 'number', sortable: false, editable: false, cellAttributes: { alignment: "left"} }
            ]);

            // load Gear Order
            var recordId = component.get("v.recordId");
            var orderName = component.get("v.orderName");
            helper.getGearOrder(component, recordId, orderName);
        }

    }, // end init
    
    // DEMOGRAPHICS TABLE OPERATIONS
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        helper.updateColumnSorting(component, fieldName, sortDirection);
    }, // end updateColumnSorting
    
    handleNumFamiliesServedChanged: function (component, event, helper) {
        var numFamiliesServed = component.get('v.order.Num_Families_Served__c');
        console.log('GearOrder_EnterBulkDemographicsController > handleNumFamiliesServedChanged - numFamiliesServed: ' + numFamiliesServed);         
        var total_PercentFamiliesServed = component.get('v.total_PercentFamiliesServed');
        if (total_PercentFamiliesServed == 100) { // recalculate NumFamiliesServed by demographic
        	helper.updateDemographicsTable(component, null);   
        }
    }, // end handleNumFamiliesServedChanged
    
    handleSave: function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log('GearOrder_EnterBulkDemographicsController > handleSave - draftValues: ' + JSON.stringify(draftValues));         
        helper.updateDemographicsTable(component, draftValues); // store the inline edit updates to the table        
    }, // end handleSave
    
    closeModel: function (component, event, helper) {
        console.log('GearOrder_EnterBulkDemographicsController > closeModel');
        
        // refresh the page, so that the new demographics will be displayed in the related list
        // TODO: not sure how to refresh the page yet. this line doesn't work
        //$A.get('e.force:refreshView').fire();

        // close the quick action modal window
        var quickAction = $A.get("e.force:closeQuickAction");
        console.log('GearOrder_EnterBulkDemographicsController > closeModel - quickAction: ' + quickAction);
        if (quickAction) {
        	quickAction.fire();  
        }
                
    }, // end closeModel
        
    createDemographics: function (component, event, helper) {
        console.log('GearOrder_EnterBulkDemographicsController > createDemographics'); 
        
        var errorMessage = "";
        
        var numFamilies_ok = false;
        var percentage_ok = false;
                
        var numFamiliesServed = component.get('v.numFamiliesServed');
        var total_PercentFamiliesServed = component.get('v.total_PercentFamiliesServed');
        
        // check num families > 0
        if (numFamiliesServed > 0) {
            numFamilies_ok = true;
        } else {
            errorMessage += '# Children Served must be greater than 0 ';
        }
        
        // check if total percentage is 100%        
        if (total_PercentFamiliesServed == 100) {
            percentage_ok = true;
        } else {
            if (errorMessage != "") { errorMessage += ", and "; }
            errorMessage += 'Total % Children Served must equal 100';
        }

        if (numFamilies_ok && percentage_ok) {
            console.log('GearOrder_EnterBulkDemographicsController > createDemographics - ok to create'); 
            var orderID = component.get("v.recordId");
            if (!orderID) orderID = component.get('v.order.Id');
            var demographicsTableData = component.get('v.demographicsTableData');
            helper.createDemographics(component, orderID, numFamiliesServed, demographicsTableData);
        } else {
            console.log('GearOrder_EnterBulkDemographicsController > createDemographics - not ok to create'); 
        	component.set('v.errorMessage', errorMessage);
        }
        
    }, // end createDemographics
    
})