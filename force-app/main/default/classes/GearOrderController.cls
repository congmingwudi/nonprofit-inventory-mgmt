public without sharing class GearOrderController {

    // ******** controller for lightning components: GearOrder_ItemEdit, GearOrder_PickupTime, GearOrder_EnterBulkDemographics

    // ******** OPERATIONS FOR lightning component: GearOrder_ItemEdit
    
    @AuraEnabled
    public static List<Account> getPartnerOrgSelection() {
       System.debug('GearOrderController > getPartnerOrgSelection');
       return [SELECT Id, Name FROM Account WHERE Type='Partner_Current' ORDER BY Name ASC];
    } // end getPartnerOrgSelection
    
    @AuraEnabled
    public static List<Gear_Order__c> getGearOrder(String orderID, String orderName) {
       	System.debug('GearOrderController > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);
       	if (orderID != null) {
       		return [SELECT Id, Name, Order_Status__c, Comment__c, Num_Children_Served__c, Line_Items__c FROM Gear_Order__c WHERE Id=:orderID];
        } else {
            return [SELECT Id, Name, Order_Status__c, Comment__c, Num_Children_Served__c, Line_Items__c FROM Gear_Order__c WHERE Name=:orderName];
        }
    } // end getGearOrder

    @AuraEnabled
    public static List<Gear_Order_Demographic__c> getGearOrderDemographicSelection(String orderID) {
       	System.debug('GearOrderController > getGearOrderDemographicSelection - orderID: ' + orderID);
        
        List<Gear_Order_Demographic__c> demographicsList =
            [SELECT Id, Name, Child_Alias__c, Child_Age__c, Child_Gender__c, Child_Race_Ethnicity__c FROM Gear_Order_Demographic__c WHERE Gear_Order__c = :orderID];        

        return demographicsList;
        
    } // end getGearOrderDemographicSelection
    
    @AuraEnabled
    public static List<Gear_Order_Item__c> getGearOrderItems(String orderID) {
       	System.debug('GearOrderController > getGearOrderItems - orderID: ' + orderID);
        
        List<Gear_Order_Item__c> orderItemList = null;
       	
        List<Gear_Order__c> orderList = getGearOrder(orderID, null);
        if (orderList.size() > 0) {
            Gear_Order__c order = orderList.get(0);          
            orderItemList = [SELECT Id, Name, Gear_Order_Demographic__c, Product__r.Id, Product__r.Name, Product__r.Family__c, Quantity__c, Season__c, Clothing_Size__c, Diaper_Size__c, Diaper_Swim_Size__c, Comment__c FROM Gear_Order_Item__c WHERE Gear_Order__c = :order.Id];        
        }
        
        if (orderItemList == null) {
            orderItemList = new List<Gear_Order_Item__c>();
        }
        
        return orderItemList;
        
    } // end getGearOrderItems    
    
    @AuraEnabled
    public static List<Product__c> getProductSelection() {
        System.debug('GearOrderController > getProductSelection');
        return ProductController.getProducts();

    } // end getProductSelection
    
    @AuraEnabled
    public static Gear_Order_Item__c createGearOrderItem(String orderID, String demographicID, 
                                                         String productID, Integer quantity, 
                                         				 String season, String clothingSize, String diaperSize,
                                                         String comment) {
        System.debug('GearOrderController > createGearOrderItem - orderID: ' + orderID  + ', demographicID:' + demographicID
        	+ ', productID: ' + productID + ', quantity: ' + quantity
        	+ ', season: ' + season + ', clothingSize: ' + clothingSize + ', diaperSize: ' + diaperSize
            + ', comment: ' + comment);
        
        // orderItem
        Gear_Order_Item__c orderItem = new Gear_Order_Item__c();
        orderItem.Gear_Order__c = orderID;
        orderItem.Gear_Order_Demographic__c = demographicID;
        orderItem.Product__c = productID;
        orderItem.Quantity__c = Integer.valueOf(quantity);
        orderItem.Season__c = season;
        orderItem.Clothing_Size__c = clothingSize;
        orderItem.Diaper_Size__c = diaperSize;
        orderItem.Comment__c = comment;                                                     
            
        insert orderItem;
        System.debug('GearOrderController > createGearOrderItem - item created: ' + orderItem);
		return orderItem;
        
    } // end createGearOrderItem
    
    @AuraEnabled 
    public static Gear_Order_Item__c updateGearOrderItem(String orderID, String orderItemID, 
                                                         String productID, Integer quantity, 
                                         				 String season, String clothingSize, String diaperSize,
                                                         String comment) {
        System.debug('GearOrderController > updateGearOrderItem - orderID: ' + orderID + ', orderItemID: ' + orderItemID
        	+ ', productID: ' + productID + ', quantity: ' + quantity
        	+ ', season: ' + season + ', clothingSize: ' + clothingSize + ', diaperSize: ' + diaperSize
            + ', comment: ' + comment);
        
        // orderItem
        Gear_Order_Item__c orderItem = new Gear_Order_Item__c();
        orderItem.Gear_Order__c = orderID;
        orderItem.Id = orderItemID;
            
        // update 
        orderItem.Product__c = productID;
        orderItem.Quantity__c = Integer.valueOf(quantity);
        orderItem.Season__c = season;
        orderItem.Clothing_Size__c = clothingSize;
        orderItem.Diaper_Size__c = diaperSize; 
        orderItem.Comment__c = comment;                                                     
            
        update orderItem;
        System.debug('GearOrderController > updateGearOrderItem - item updated: ' + orderItem);
        return orderItem;
        
    } // end updateGearOrderItem      
    
    @AuraEnabled
    public static Gear_Order_Item__c deleteGearOrderItem(String orderID, String orderItemID) {
        System.debug('GearOrderController > deleteGearOrderItem - orderID: ' + orderID + ', orderItemID: ' + orderItemID);
        
        Gear_Order_Item__c orderItem = new Gear_Order_Item__c();
        orderItem.Gear_Order__c = orderID;
        orderItem.Id = orderItemID;
        
        delete orderItem;
        System.debug('GearOrderController > deleteGearOrderItem - item deleted: ' + orderItem);
        return orderItem;
        
    } // end updateGearOrderItem   
    
    // Option - inner class 
    public class Option {
        @AuraEnabled
        String label {get;set;}
        @AuraEnabled
        String value {get;set;}
        @AuraEnabled
        Boolean defaultValue {get;set;}
    }
    
    // getPicklistValues - returns a list of inner class Option
    @AuraEnabled
    public static List<Option> getPicklistValues(SObject obj, String field) {
        System.debug('GearOrderController > getPicklistValues - obj: ' + obj + ', field: ' + field);
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
            if (a.isDefaultValue()) {
                option.defaultValue = true;
            }            
            options.add(option);
        }
        
        System.debug('GearOrderController > getPicklistValues - values: ' + options);
        //options.sort();
        return options;
    } // getPicklistValues
    
    @AuraEnabled 
    public static String updateOrderComment(String orderID, String comment) {
        System.debug('GearOrderController > updateOrderComment - orderID: ' + orderID + ', comment: ' + comment);
        
        // order
        Gear_Order__c order = new Gear_Order__c();
        order.Id = orderID;
            
        // update 
        order.Comment__c =  comment;
            
        update order;
        System.debug('GearOrderController > updateOrderComment - order updated: ' + order);
        return 'ORDER_UPDATED';
        
    } // end updateOrderComment    
    
    // ******** OPERATIONS FOR lightning component: GearOrder_PickupTime

    @AuraEnabled
    public static List<String> getNextPickupDatesAvailable(Integer numDates) {
        // dateString format '04/14/2019'
        // returns a list of dates, the next dates available for order pickup.
        // numDates - indicates the number of future available dates to return.
        // availability is determined by querying 'all day' calendar events that have the subject 'ORDER PICKUPS'
        // that start today or in the future.

        System.debug('GearOrderController > getNextPickupDatesAvailable - numDates: ' + numDates);

        String availableEventName = 'ORDER PICKUPS';

        // example query:
        // SELECT Owner.Name, StartDateTime from Event WHERE IsAllDayEvent=true AND Subject='ORDER PICKUPS' AND StartDateTime >= TODAY ORDER BY StartDateTime LIMIT 3
        String query = 'SELECT StartDateTime FROM Event';

        // where clause
        String whereClause = 'WHERE Subject=\'' + availableEventName + '\' AND IsAllDayEvent=true AND ActivityDate >= TODAY';
        query += ' ' + whereClause + ' ORDER BY ActivityDate LIMIT ' + numDates;
        System.debug('GearOrderController > getNextPickupDatesAvailable - query: ' + query);

        List<String> nextDates = new List<String>();

        List<Event> availableEvents = Database.query(query);
        if ((availableEvents != null) && (availableEvents.size() > 0)) {
            System.debug('GearOrderController > getNextPickupDatesAvailable - availableEvents: ' + availableEvents);

            for (Integer i = 0; i < availableEvents.size(); ++i) {
                DateTime eventDate = availableEvents[i].StartDateTime;
                String eventDateString = eventDate.format('MM/dd/yyyy', 'GMT');
                //System.debug('GearOrderController > getNextPickupDatesAvailable - eventDate: ' + eventDate);
                nextDates.add(eventDateString);
            }
        }

        System.debug('GearOrderController > getNextPickupDatesAvailable - nextDates: ' + nextDates);
        return nextDates;

    } // end getNextPickupDatesAvailable
    
    @AuraEnabled 
    public static String updatePreferredPickupTimes(String orderID, Boolean noTimesWork, String noTimesWorkComment, String pickupTimezone, String pickupDateTime1String, String pickupDateTime2String) {
    	// dateTimeString format '11/10/2018 10:00 am'
    	// 
        System.debug('GearOrderDemographicsController > updatePreferredPickupTimes - orderID: ' + orderID + ', noTimesWork: ' + noTimesWork + ', noTimesWorkComment: ' + noTimesWorkComment + ', pickupTimezone: ' + pickupTimezone + ', pickupDateTime1String: ' + pickupDateTime1String + ', pickupDateTime2String: ' + pickupDateTime2String);

        // order
        Gear_Order__c order = new Gear_Order__c();
        order.Id = orderID;
        
        // update noTimesWork
        if (noTimesWork) {
            order.NoTimesWork__c = true;
            order.NoTimesWork_Comment__c = noTimesWorkComment;
            
            // unset pickup choices
            order.Pickup_Choice_1__c =  null;
        	order.Pickup_Choice_2__c =  null;
        }
            
        // update pickup choices        
        if ((pickupDateTime1String != null) && (pickupDateTime2String != null)) {
            
            // parse into dates (string format: 10/14/2011 11:46 AM) and adjust to pickupTimezone
            DateTime pickupDateTime1 = getTimezoneAdjustedDate(pickupTimezone, pickupDateTime1String);
            DateTime pickupDateTime2 = getTimezoneAdjustedDate(pickupTimezone, pickupDateTime2String);
            System.debug('GearOrderDemographicsController > updatePreferredPickupTimes - pickupDateTime1: ' + pickupDateTime1 + ', pickupDateTime2: ' + pickupDateTime2);
        	order.Pickup_Choice_1__c =  pickupDateTime1;
        	order.Pickup_Choice_2__c =  pickupDateTime2;
            
            // unset NoTimesWork
            order.NoTimesWork__c = false;
            order.NoTimesWork_Comment__c = null;
        }
            
        update order;
        System.debug('GearOrderDemographicsController > updatePreferredPickupTimes - order updated: ' + order);
        return 'ORDER_UPDATED - user timezone: ' + UserInfo.getTimeZone().getID();
        
    } // end updateOrderComment 
    
    public static DateTime getTimezoneAdjustedDate(String targetTimezone, String dateTimeString) {
        // dateTimeString format '11/10/2018 10:00 am'
            
		System.debug('GearOrderController > getTimezoneAdjustedDate - targetTimezone: ' + targetTimezone  + ', dateTimeString: ' + dateTimeString);
        
        // parse into dates (string format: 11/10/2018 10:00 am) and adjust to pickupTimezone
        // for now assuming the date created from DateTime.parse is in GMT time 
        // because this is called from an unauthenticated user       
        
        // what the time looks like coming in
        DateTime theDateTime = parseDateTimeStringGMT(dateTimeString);
        //DateTime theDateTime = DateTime.parse(dateTimeString);
        System.debug('GearOrderController > getTimezoneAdjustedDate - theDateTime (GMT): ' + theDateTime);
    
        // adjust the stored UTC time based on the offset of the given timezone (this automatically adjusts for daylight savings time)
        TimeZone target_tz = Timezone.getTimeZone(targetTimezone);
        Long timezoneOffset = target_tz.getOffset(theDateTime);
        Long minDiff = timezoneOffset / 1000 / 60;
        Long hourDiff = minDiff / 60;
        System.debug('GearOrderController > getTimezoneAdjustedDate - target timezone: ' + target_tz.getDisplayName() + ', id: ' + target_tz.getID() + ', offset: ' + timezoneOffset + ' (' + hourDiff +' hours)');
        DateTime adjustedDateTime = theDateTime.addMinutes(minDiff.intValue() * -1);
        String theDateTime_gmt = adjustedDateTime.format('yyyy-MM-dd HH:mm:ss', 'GMT');
        String theDateTime_targetTimezone = adjustedDateTime.format('yyyy-MM-dd HH:mm:ss', targetTimezone);            
        System.debug('GearOrderController > getTimezoneAdjustedDate - theDateTime (adjusted) gmt: ' + theDateTime_gmt + ', targetTimezone: ' + targetTimezone  + ', theDateTime_targetTimezone: ' + theDateTime_targetTimezone);
        
        return adjustedDateTime; 
        
    } // end getTimezoneAdjustedDate
    
    public static DateTime parseDateTimeStringGMT(String dateTimeString) {
        // parse dateTimeString format '11/10/2018 10:00 am'
        // and create DateTime in GMT
        DateTime theDate = null;
        
        List<String> toks = dateTimeString.split(' ');
        //System.debug('toks: ' + toks + ', size: ' + toks.size());
        
        // date
        List<String> dateToks = toks[0].split('/');
        //System.debug('dateToks: ' + dateToks);
        Integer month = Integer.valueof(dateToks[0]);
        Integer day = Integer.valueof(dateToks[1]);
        Integer year = Integer.valueof(dateToks[2]);
        //System.debug('year: ' + year + ', month: ' + month + ', day: ' + day);
        
        // time
        if (toks.size() == 3) {
            List<String> timeToks = toks[1].split(':');
            Integer hour = Integer.valueof(timeToks[0]);
            Integer minute = Integer.valueof(timeToks[1]);
            String am_pm = toks[2];
            //System.debug('hour: ' + hour + ', minute: ' + minute + ', am_pm: ' + am_pm);
            
            if ((am_pm == 'pm') && (hour != 12)) {
                hour += 12;
            } else if ((am_pm == 'am') && (hour == 12)) {
                hour = 0;
            }
            
            //System.debug('year: ' + year + ', month: ' + month + ', day: ' + day + ', hour: ' + hour + ', minute: ' + minute );
            theDate = DateTime.newInstanceGmt(year, month, day, hour, minute, 0);
        } else {
            theDate = DateTime.newInstanceGmt(year, month, day);
        }
        
        System.debug('GearOrderController > parseDateTimeStringGMT - theDate: ' + theDate);
        return theDate;
        
    } // end parseDateTimeStringGMT
    
    // ******** OPERATIONS FOR lightning component: GearOrder_EnterBulkDemographics 

    @AuraEnabled
    public static List<Gear_Order__c> getGearOrderForBulkDemographics(String orderID, String orderName) {
       	System.debug('GearOrderController > getGearOrderForBulkDemographics - orderID: ' + orderID + ', orderName: ' + orderName);
       	if (orderID != null) {
       		return [SELECT Id, Name, Partner_Organization__c, Num_Families_Served__c FROM Gear_Order__c WHERE Id=:orderID];
        } else {
            return [SELECT Id, Name, Partner_Organization__c, Num_Families_Served__c FROM Gear_Order__c WHERE Name=:orderName];
        }
    } // end getGearOrder

    @AuraEnabled
    public static DemographicsServedDetails getDemographicsServed(String accountID) {
        System.debug('GearOrderController > getDemographicsServed - accountID: ' + accountID);
        DemographicsServedDetails details;
        if (accountID != null) {
            details = new DemographicsServedDetails();

            // numFamiliesServed
            Account account = [SELECT Families_Receiving_Support__c FROM Account WHERE ID = :accountID LIMIT 1];
            System.debug('GearOrderController > getDemographicsServed - account: ' + account);
            Decimal numFamilesServed = account.Families_Receiving_Support__c;
            if (numFamilesServed == null) numFamilesServed = 0;
            details.numFamiliesServed = Integer.valueOf(numFamilesServed);

            // demographicServedList
            Gear_Order_Demographic__c obj = new Gear_Order_Demographic__c();
            String field = 'Child_Race_Ethnicity__c';
            List<Option> options = getPicklistValues(obj, field);

            // map of race/ethnicity : Demographic_Served__c
            List<Demographic_Served__c> demographicServedList = [SELECT Id, Race_Ethnicity__c, Percent_Served__c FROM Demographic_Served__c WHERE Partner_Organization__c=:accountID];
            Map<String, Demographic_Served__c> demographicMap = new Map<String, Demographic_Served__c>();
            for (Demographic_Served__c d : demographicServedList) {
                demographicMap.put(d.Race_Ethnicity__c, d);
            }

            // add any picklist race_ethnicity values that aren't in the existing account demographics served
            // so that they'll display in the table for editing
            for (Option o : options) {
                if (!demographicMap.containsKey(o.label)) {
                    Demographic_Served__c d = new Demographic_Served__c(Race_Ethnicity__c = o.label, Percent_Served__c = 0);
                    demographicServedList.add(d);
                }
            }
            details.demographicServedList = demographicServedList;
        }
        return details;
    } // end getDemographicsServed

    // DemographicsServedDetails - inner class used as return type from getDemographicsServed
    public class DemographicsServedDetails {
        @AuraEnabled
        List<Demographic_Served__c> demographicServedList {get;set;}
        @AuraEnabled
        Integer numFamiliesServed {get;set;}
    }

    @AuraEnabled
    public static List<String> createGearOrderDemographics(String orderID, Integer totalNumFamiliesServed, String demographicList) {
       	System.debug('GearOrderController > createGearOrderDemographics - orderID: ' + orderID + ', totalNumFamiliesServed: ' + Double.valueOf(totalNumFamiliesServed) + ', demographicList: ' + demographicList);
       	
        // update Gear Order num families served and bulk demographics flag
        Gear_Order__c order = new Gear_Order__c(Id=orderID);
       	order.Num_Families_Served__c = Double.valueOf(totalNumFamiliesServed);
        order.Bulk_Demographics__c = true;
        update order;
        
        // deserialize demographicList json
        List<Object> oList = (List<Object>)JSON.deserializeUntyped(demographicList);
        List<Gear_Order_Demographic__c> orderDemographicList = new List<Gear_Order_Demographic__c>();
        
        System.debug('GearOrderController > createGearOrderDemographics - demographicList: ' + oList + ', list size: ' + oList.size());
        
        for (Integer i = 0; i < oList.size(); ++i) {
            
            Object o = oList.get(i);
            //System.debug('GearOrderController > createGearOrderDemographics - demographic: ' + o);
            
            Map<String, Object> m = (Map<String, Object>) o;
            
            String raceEthnicity = (String) m.get('RaceEthnicity');
        	Integer percentFamiliesServed = Integer.valueOf(m.get('PercentFamiliesServed'));
        	Integer numFamiliesServed = Integer.valueOf(m.get('NumFamiliesServed'));
            
            if (percentFamiliesServed > 0) {
            	// create a set of Gear_Order_Demographic records for the number of families served (NumFamiliesServed) for each RaceEthnicity
            	System.debug('GearOrderController > createGearOrderDemographics - for RaceEthnicity: ' + raceEthnicity + ', creating this number of Gear_Order_Demographic: ' + numFamiliesServed);                        
        	
				for (Integer j = 0; j < numFamiliesServed; ++j) {
                
                    // gear order demographic
                    Gear_Order_Demographic__c orderDemographic = new Gear_Order_Demographic__c();
                    orderDemographic.Gear_Order__c = orderID;
                    orderDemographic.Child_Race_Ethnicity__c = raceEthnicity;
                    orderDemographicList.add(orderDemographic);
                    
                } // end for numFamiliesServed
                
            } // end if percentFamiliesServed > 0
            
        } // for oList
        
        //System.debug('GearOrderController > createGearOrderDemographics - orderDemographicList: ' + orderDemographicList);
        insert orderDemographicList;
        
        List<String> responseList = new List<String>();
        responseList.add('success');
        return responseList;
    } // end getGearOrder

    
} // GearOrderController