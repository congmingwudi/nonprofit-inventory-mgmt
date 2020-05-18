public with sharing class GearOrderDemographicsController {
   
    // ******** controller for lightning component: GearOrder_DemographicsEdit 
    
    @AuraEnabled
    public static List<Gear_Order__c> getGearOrder(String orderID, String orderName) {
       	System.debug('GearOrderDemographicsController > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);
       	if (orderID != null) {
       		return [SELECT Id, Name, Order_Status__c, Num_Families_Served__c FROM Gear_Order__c WHERE Id=:orderID];
        } else {
            return [SELECT Id, Name, Order_Status__c, Num_Families_Served__c FROM Gear_Order__c WHERE Name=:orderName];
        }
    } // end getGearOrder
    
    @AuraEnabled
    public static List<Gear_Order_Demographic__c> getGearOrderDemographics(String orderID) {
       	System.debug('GearOrderDemographicsController > getGearOrderDemographics - orderID: ' + orderID);
        
        List<Gear_Order_Demographic__c> demographicsList =
            [SELECT Id, Name, Child_Alias__c, Child_Age__c, Child_Gender__c, Child_Race_Ethnicity__c, Parent_Age__c, Parent_Gender__c, Parent_Race_Ethnicity__c, Parent_Marital_Status__c, Comment__c FROM Gear_Order_Demographic__c WHERE Gear_Order__c = :orderID];        
        
        return demographicsList;
        
    } // end getGearOrderDemographics

    @AuraEnabled
    public static List<Gear_Order_Sibling_Demographic__c> getGearOrderSiblingDemographics(String demographicID) {
       	System.debug('GearOrderDemographicsController > getGearOrderSiblingDemographics - demographicID: ' + demographicID);
        
        List<Gear_Order_Sibling_Demographic__c> siblingsList =
            [SELECT Id, Name, Sibling_Age__c, Sibling_Gender__c FROM Gear_Order_Sibling_Demographic__c WHERE Gear_Order_Demographic__c = :demographicID];        
        
        return siblingsList;
        
    } // end getGearOrderSiblingDemographics
    
    // Option - inner class 
    public class Option {
        @AuraEnabled
        String label {get;set;}
        @AuraEnabled
        String value {get;set;}
    }
    
    // getPicklistValues - returns a list of inner class Option
    @AuraEnabled
    public static List<Option> getPicklistValues(SObject obj, String field) {
        System.debug('GearOrderDemographicsController > getPicklistValues - obj: ' + obj + ', field: ' + field);
        List<Option> options = new List<Option>();
        
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        Map< String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> pickListOptions = fieldMap.get(field).getDescribe().getPickListValues();
        
        // Add these values to the select option list
        for (Schema.PicklistEntry a: pickListOptions) {
            Option option = new Option();
            option.label = a.getLabel();
            option.value = a.getValue();
            options.add(option);
        }
        
        System.debug('GearOrderDemographicsController > getPicklistValues - values: ' + options);
        //options.sort();
        return options;
        
    } // getPicklistValues    
    
    @AuraEnabled
    public static Gear_Order_Demographic__c createGearOrderDemographic(String orderID, String childAlias, 
                            String childGender, String childAge, String childRaceEthnicity, 
                            String parentGender, String parentAge, String parentRaceEthnicity, String parentMaritalStatus,
                            String comment) {
                                
        	System.debug('GearOrderDemographicsController > createGearOrderDemographic - orderID: ' + orderID  + ', childAlias:' + childAlias
            + ', childGender:' + childGender + ', childAge:' + childAge + ', childRaceEthnicity:' + childRaceEthnicity
        	+ ', parentGender:' + parentGender + ', parentAge:' + parentAge + ', parentRaceEthnicity:' + parentRaceEthnicity + ', parentMaritalStatus:' + parentMaritalStatus
        	+ ', comment: ' + comment);
        
            // demographic
            Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
            demographic.Gear_Order__c = orderID;
            demographic.Child_Alias__c = childAlias;
            demographic.Child_Gender__c = childGender;
            demographic.Child_Age__c = childAge;
            demographic.Child_Race_Ethnicity__c = childRaceEthnicity;
            demographic.Parent_Gender__c = parentGender;
            demographic.Parent_Age__c = parentAge;
            demographic.Parent_Race_Ethnicity__c = parentRaceEthnicity;
            demographic.Parent_Marital_Status__c = parentMaritalStatus;
            demographic.Comment__c = comment;                    
                
            // insert
            System.debug('GearOrderDemographicsController > createGearOrderDemographic - inserting demographic: ' + demographic);
            insert demographic;
            return demographic;                                
        
    } // end createGearOrderDemographic 
    
    @AuraEnabled
    public static Gear_Order_Demographic__c updateGearOrderDemographic(String orderID, String demographicID, String childAlias, 
                            String childGender, String childAge, String childRaceEthnicity, 
                            String parentGender, String parentAge, String parentRaceEthnicity, String parentMaritalStatus,
                            String comment) {
                                
        	System.debug('GearOrderDemographicsController > updateGearOrderDemographic - orderID: ' + orderID + ', demographicID:' + demographicID + ', childAlias:' + childAlias
            + ', childGender:' + childGender + ', childAge:' + childAge + ', childRaceEthnicity:' + childRaceEthnicity
        	+ ', parentGender:' + parentGender + ', parentAge:' + parentAge + ', parentRaceEthnicity:' + parentRaceEthnicity + ', parentMaritalStatus:' + parentMaritalStatus
        	+ ', comment: ' + comment);
                                
            // demographic
            Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();
            demographic.Gear_Order__c = orderID;
            demographic.Id = demographicID;
            
            // update 
            demographic.Child_Alias__c = childAlias;
            demographic.Child_Gender__c = childGender;
            demographic.Child_Age__c = childAge;
            demographic.Child_Race_Ethnicity__c = childRaceEthnicity;
            demographic.Parent_Gender__c = parentGender;
            demographic.Parent_Age__c = parentAge;
            demographic.Parent_Race_Ethnicity__c = parentRaceEthnicity;
            demographic.Parent_Marital_Status__c = parentMaritalStatus;
            demographic.Comment__c = comment;                    
                
            // update
            System.debug('GearOrderDemographicsController > updateGearOrderDemographic - updating demographic: ' + demographic);
            update demographic;
            return demographic;                                
        
    } // end updateGearOrderDemographic     

    @AuraEnabled
    public static Gear_Order_Demographic__c deleteGearOrderDemographic(String orderID, String demographicID) {
        System.debug('GearOrderDemographicsController > deleteGearOrderDemographic - orderID: ' + orderID + ', demographicID: ' + demographicID);
        
        // demographic
        Gear_Order_Demographic__c demographic = new Gear_Order_Demographic__c();        
        demographic.Gear_Order__c = orderID;
        demographic.Id = demographicID;
        
        delete demographic;
        System.debug('GearOrderDemographicsController > deleteGearOrderDemographic - demographic deleted: ' + demographic);
        return demographic;
        
    } // end deleteGearOrderDemographic

    @AuraEnabled 
    public static String updateNumFamiliesServed(String orderID, Integer numFamiliesServed) {
        System.debug('GearOrderDemographicsController > updateNumFamiliesServed - orderID: ' + orderID + ', numFamiliesServed: ' + numFamiliesServed);
        
            // order
            Gear_Order__c order = new Gear_Order__c();
            order.Id = orderID;
            
            // update 
            order.Num_Families_Served__c =  numFamiliesServed;
            
            update order;
            System.debug('GearOrderDemographicsController > updateNumFamiliesServed - order updated: ' + order);
            return 'ORDER_UPDATED';
        
    } // end updateNumFamiliesServed
    
    @AuraEnabled
    public static List<String> updateDemographics(String orderID, String demographicList) {
       	System.debug('GearOrderDemographicsController > updateDemographics - orderID: ' + orderID + ', demographicList: ' + demographicList);       	
        
        // deserialize demographicList json that will look like this: [{"ChildAlias":"Bob","Name":"GOD-0000000245"}]
        List<Object> oList = (List<Object>)JSON.deserializeUntyped(demographicList);
        List<Gear_Order_Demographic__c> toUpdateDemographicList = new List<Gear_Order_Demographic__c>();
        
        System.debug('GearOrderDemographicsController > updateDemographics - demographicList: ' + oList + ', list size: ' + oList.size());
        
        for (Integer i = 0; i < oList.size(); ++i) {
            
            Object o = oList.get(i);
            System.debug('GearOrderDemographicsController > updateDemographics - demographic: ' + o);
            
            Map<String, Object> m = (Map<String, Object>) o;
            
            String name = (String) m.get('Name');
            String childAlias = (String) m.get('ChildAlias');
            
			List<Gear_Order_Demographic__c> orderDemographicList = [SELECT Id FROM Gear_Order_Demographic__c WHERE Name = :name];
            if (orderDemographicList.size() > 0) {
                Gear_Order_Demographic__c demographic = orderDemographicList.get(0);
                demographic.Child_Alias__c = childAlias; // update 
                toUpdateDemographicList.add(demographic);
            }
                    
        } // for oList
        
        System.debug('GearOrderDemographicsController > updateDemographics - toUpdateDemographicList: ' + toUpdateDemographicList);
        update toUpdateDemographicList;
        
        List<String> responseList = new List<String>();
        responseList.add('success');
        return responseList;
        
    } // end updateDemographics
    
    @AuraEnabled
    public static Gear_Order_Sibling_Demographic__c createGearOrderSiblingDemographic(String demographicID, 
                            String siblingGender, String siblingAge) {
                                
        	System.debug('GearOrderDemographicsController > createGearOrderSiblingDemographic - demographicID: ' + demographicID
            	+ ', siblingGender:' + siblingGender + ', siblingAge:' + siblingAge);
                    
            // sibling demographic
            Gear_Order_Sibling_Demographic__c sibling = new Gear_Order_Sibling_Demographic__c();
            sibling.Gear_Order_Demographic__c = demographicID;
            sibling.Sibling_Gender__c = siblingGender;
            sibling.Sibling_Age__c = siblingAge;
                
            // insert
            System.debug('GearOrderDemographicsController > createGearOrderSiblingDemographic - inserting sibling demographic: ' + sibling);
            insert sibling;
            return sibling;                                
        
    } // end createGearOrderSiblingDemographic 
    
    @AuraEnabled
    public static Gear_Order_Sibling_Demographic__c updateGearOrderSiblingDemographic(String siblingDemographicID, 
                            String siblingGender, String siblingAge) {
                                
        	System.debug('GearOrderDemographicsController > updateGearOrderSiblingDemographic - siblingDemographicID: ' + siblingDemographicID
            	+ ', siblingGender:' + siblingGender + ', siblingAge:' + siblingAge);
                                
            // sibling demographic
            Gear_Order_Sibling_Demographic__c sibling = new Gear_Order_Sibling_Demographic__c();
            sibling.Id = siblingDemographicID;
            
            // update 
            sibling.Sibling_Gender__c = siblingGender;
            sibling.Sibling_Age__c = siblingAge;                  
                
            // update
            System.debug('GearOrderDemographicsController > updateGearOrderSiblingDemographic - updating sibling demographic: ' + sibling);
            update sibling;
            return sibling;                                
        
    } // end updateGearOrderSiblingDemographic     

    @AuraEnabled
    public static Gear_Order_Sibling_Demographic__c deleteGearOrderSiblingDemographic(String siblingDemographicID) {
        System.debug('GearOrderDemographicsController > deleteGearOrderSiblingDemographic - siblingDemographicID: ' + siblingDemographicID);
        
        // sibling demographic
        Gear_Order_Sibling_Demographic__c sibling = new Gear_Order_Sibling_Demographic__c();
        sibling.Id = siblingDemographicID;
        
        delete sibling;
        System.debug('GearOrderDemographicsController > deleteGearOrderSiblingDemographic - sibling demographic deleted: ' + sibling);
        return sibling;
        
    } // end deleteGearOrderSiblingDemographic    
    
    
} // GearOrderDemographicsController