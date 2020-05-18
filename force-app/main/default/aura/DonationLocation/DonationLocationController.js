({
    
	init: function(component, event, helper) {

		var location = component.get("v.location");
		var address = location.Street_Address__c + ', ' + location.City__c + ', ' + location.State__c + ' ' + location.Zip_Code__c;
		component.set("v.address", address);
        
	} // end init
    
})