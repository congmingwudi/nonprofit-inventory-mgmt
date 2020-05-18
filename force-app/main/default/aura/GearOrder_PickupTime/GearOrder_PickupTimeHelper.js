({

    getGearOrder: function(component, orderID, orderName) {
        
        // retrieve Gear Order
        console.log('GearOrder_PickupTimeControllerHelper > getGearOrder - orderID: ' + orderID + ', orderName: ' + orderName);        
        
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
            console.log('GearOrder_PickupTimeControllerHelper > getGearOrder response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                
               	// orderList                
                var orderList = response.getReturnValue();
            	//console.log('GearOrder_PickupTimeControllerHelper > getGearOrder orderList: ' + JSON.stringify(orderList));
                
                if (orderList.length > 0) {
                    var order = orderList[0];
                    component.set("v.order", order);
                    component.set("v.orderID", order.Id);
                    component.set("v.orderName", order.Name);
                }
                
            }
            else {
                console.log("GearOrder_PickupTimeControllerHelper > getGearOrder - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end getGearOrder

    setPickupDates: function(component) {

        console.log('GearOrder_PickupTimeControllerHelper > setPickupDates');

        this.getNextPickupDatesAvailable(component)
            .then(() => {
                var days = component.get("v.days");
                console.log('GearOrder_PickupTimeControllerHelper > setPickupDates - days (' + days.length + '): ' + JSON.stringify(days));

                var dateOptions = [];

                if (days) {

                    for(var i = 0; i < days.length; ++i) {
                        // set date option
                        var dateString = days[i];
                        var day = new Date(dateString);
                        console.log('GearOrder_PickupTimeControllerHelper > setPickupDates - dateString: ' + dateString + ', day: ' + JSON.stringify(day));
                        var dayString = this.formatDateString(day);
                        var dayID = dateString; //this.formatDateID(day);
                        dateOptions[i] = { "label":dayString, "id":dayID };

                        // set default pickup dates
                        if (i == 0) {
                            component.set("v.pickup_date1", dayID);
                            component.set("v.pickup_date2", dayID);
                        }
                    }

                    component.set("v.pickup_dateList", dateOptions);
                    console.log('GearOrder_PickupTimeControllerHelper > setPickupDates - dateOptions: ' + JSON.stringify(dateOptions));

                }

                if (!days || (dateOptions.length == 0)) {
                    // disable pickup times and enable noTimeWork section
                    component.set("v.noTimesWork", true);
                    component.set("v.noTimesWorkDisabled", true);
                }

            })
            .catch(err => {
                console.error('GearOrder_PickupTimeControllerHelper > setPickupDates - error: ' + err.message);
            })

	}, // end setPickupDates

    formatDateString: function(date) {
        // formats date as day, month time = "Sun, Jan 10"
        var days = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"];
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
 		return days[date.getUTCDay()] + ', ' + months[date.getUTCMonth()] + ' ' + date.getUTCDate();
    },

    /*
    formatDateID: function(date) {
        // formats date as month/day/year = 11/08/2018
		return (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear();
    },
    */

    getNextPickupDatesAvailable: function(component) {

        return new Promise((resolve, reject) => {

            var numDates = component.get("v.numDates");
            console.log('GearOrder_PickupTimeControllerHelper > getNextPickupDatesAvailable - numDates: ' + numDates);

            // Create the action
            var doAction = true;
            var action = component.get("c.getNextPickupDatesAvailable"); // method on the GearOrderController
            action.setParams({
                "numDates": numDates
            });

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                console.log('GearOrder_PickupTimeControllerHelper > getNextPickupDatesAvailable response: ' + response.getState())
                var state = response.getState();
                if (state === "SUCCESS") {

                    // nextDates
                    var nextDates = response.getReturnValue();
                    console.log('GearOrder_PickupTimeControllerHelper > getNextPickupDatesAvailable - nextDates: ' + JSON.stringify(nextDates));
                    component.set("v.days", nextDates);

                    // promise resolved
                    resolve();

                }
                else {
                    // promise rejected - throw error
                    console.log("GearOrder_PickupTimeControllerHelper > getNextPickupDatesAvailable - failed with state: " + state);
                    var error = new Error('failed with state: ' + state);
                    reject(error);
                }
            });

            // Send action off to be executed
            if (doAction) {
                $A.enqueueAction(action);
            }

        }) // end promise

    }, // end getNextPickupDatesAvailable

    setPickupTimes: function(component) {
        
        // preferred pickup times
        var selectAuraID = 'pickupTime';
        var componentPickListAttribute = 'pickup_timeList';
        var componentDefaultAttribute = 'pickup_timeDefault';
        var objectName = 'Gear_Order__c';
        var objectField = 'Preferred_Pickup_Times__c';
        this.getPicklistValues(component, componentPickListAttribute, componentDefaultAttribute, objectName, objectField, selectAuraID);  
        
    }, // end setPickupTimes
    
    getPicklistValues: function(component, componentPickListAttribute, componentDefaultAttribute, objectName, objectField, selectAuraID) {
        
        console.log('GearOrder_PickupTimeControllerHelper > getPicklistValues - componentPickListAttribute: ' + componentPickListAttribute + ', componentDefaultAttribute: ' + componentDefaultAttribute + ', objectName: ' + objectName + ', objectField: ' + objectField + ', selectAuraID: ' + selectAuraID);
        
        // Create the action
        var action = component.get("c.getPicklistValues"); // method on the GearOrderController
        action.setParams({
            "obj": {sobjectType : objectName},
            "field": objectField
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_PickupTimeControllerHelper > getPicklistValues response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                console.log('GearOrder_PickupTimeControllerHelper > getPicklistValues - returnValue: ' + JSON.stringify(options));
            	component.set("v." + componentPickListAttribute, options);
				
				// set default picklist value
                for (var i = 0; i < options.length; ++i) {
                    var o = options[i];
                    //console.log('GearOrder_PickupTimeControllerHelper > option: ' + JSON.stringify(o) + ', isDefault: ' + o.defaultValue);
                    if (o.defaultValue) {
                        component.set("v." + componentDefaultAttribute, o.value);
                        var defaultValue = component.get("v." + componentDefaultAttribute);
                        console.log('GearOrder_PickupTimeControllerHelper > default value set: ' + o.value);

                        // let DOM state catch up to set default picklist values
                        window.setTimeout(
                            $A.getCallback( function() {
                                // set default times
                                component.set("v.pickup_time1", defaultValue);
        						component.set("v.pickup_time2", defaultValue);
                            }));
                        
                    } // end if defaultValue
                } // end for
            }
            else {
                console.log("GearOrder_PickupTimeControllerHelper > getPicklistValues - failed with state: " + state);
            }
        });

        // Send action off to be executed
		$A.enqueueAction(action);
        
    }, // end getPicklistValues	     

    setPickupDateTimes: function (component) {
        
        var dateTime1;
        var dateTime2;
        
        var noTimesWork = component.get("v.noTimesWork");
        console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - noTimesWork: ' + noTimesWork);
		var noTimesWorkComment; 
        
        if (noTimesWork) {
            
            noTimesWorkComment = component.get("v.noTimesWorkComment");
            console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - noTimesWorkComment: ' + noTimesWorkComment);
            if (noTimesWorkComment == "") noTimesWorkComment = null;
            dateTime1 = null;
            dateTime2 = null;
          
        } else { // formats preferred pickup dateTime into string for apex controller: 10/14/2011 11:46 AM
            
            // preferred time 1
            var date1 = component.get("v.pickup_date1");
            var time1 = component.get("v.pickup_time1");
            console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - date1: ' + date1 + ', time1: ' + time1);
            
            dateTime1 = this.getDateTimeString(component, date1, time1);
            console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - dateTime1: ' + dateTime1);
    
            // preferred time 2
            var date2 = component.get("v.pickup_date2");
            var time2 = component.get("v.pickup_time2");
            console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - date2: ' + date2 + ', time2: ' + time2);
            
            dateTime2 = this.getDateTimeString(component, date2, time2);
            console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - dateTime2: ' + dateTime2);
        }
           
		// update the Gear Order preferred pickup times		
        var orderID = component.get("v.orderID");
        var pickupTimezone = component.get("v.pickup_timeZone");
        this.savePreferredPickupTimes(component, orderID, noTimesWork, noTimesWorkComment, pickupTimezone, dateTime1, dateTime2);

	}, // end setPickupDateTimes
    
    /*
     * returns date string in format: 11/10/2018 9:00 AM
     * so that it can be parsed into a DateTime in the apex controller
     */
    getDateTimeString: function (component, dateString, timeString) {
 
        // if time is null, set default time
        if (!timeString) { 
        	var pickup_timeList = component.get("v.pickup_timeList");
            console.log('GearOrder_PickupTimeControllerHelper > setPickupDateTimes - pickup_timeList: ' + JSON.stringify(pickup_timeList[0]));
            timeString = pickup_timeList[0].value; 
        }
       
        return dateString + ' ' + timeString;
        
    }, // end getDateTimeString
    
    savePreferredPickupTimes: function(component, orderID, noTimesWork, noTimesWorkComment, pickupTimezone, pickupDateTime1String, pickupDateTime2String) {
    
        console.log('GearOrder_PickupTimeControllerHelper > savePreferredPickupTimes - orderID: ' + orderID + ', noTimesWork: ' + noTimesWork + ', noTimesWorkComment: ' + noTimesWorkComment + ', pickupTimezone: ' + pickupTimezone + ', pickupDateTime1: ' + pickupDateTime1String + ', pickupDateTime2: ' + pickupDateTime2String);        
        
        // Create the action
        var doAction = true;
        var action = component.get("c.updatePreferredPickupTimes"); // method on the GearOrderController
        if (orderID != '') {
            action.setParams({
                "orderID": orderID,
                "noTimesWork": noTimesWork,
                "noTimesWorkComment": noTimesWorkComment,
                "pickupTimezone": pickupTimezone,
                "pickupDateTime1String": pickupDateTime1String,
                "pickupDateTime2String": pickupDateTime2String,
            });        
        } else {
            // required input parameters missing
            doAction = false;
        }
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('GearOrder_PickupTimeControllerHelper > updatePreferredPickupTimes - response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {                
               	// responseStatus                
                var responseStatus = response.getReturnValue();
            	console.log('GearOrder_PickupTimeControllerHelper > updatePreferredPickupTimes - responseStatus: ' + JSON.stringify(responseStatus));           
            }
            else {
                console.log("GearOrder_PickupTimeControllerHelper > updatePreferredPickupTimes - failed with state: " + state);
            }
        });

        // Send action off to be executed
        if (doAction) {
        	$A.enqueueAction(action);
        }
        
    }, // end updatePreferredPickupTimes    
    
    validateFields: function (component) {
        
        var allGood = false;
        var errorMessage = "";

        // validate 
        allGood = true;
       
        // set error message
        component.set("v.errorMessage", errorMessage);
        
		return allGood;
        
	}, // end validateFields 
       
});