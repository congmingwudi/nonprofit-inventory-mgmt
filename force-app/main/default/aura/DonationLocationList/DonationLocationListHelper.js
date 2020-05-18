/**
 * Created by ryan.cox on 2019-02-06.
 */
({

    getDonationLocations: function(component) {

        // retrieve Donation Locations
        console.log('DonationLocationListHelper > getDonationLocations')

        // Create the action
        var action = component.get("c.getDonationLocations"); // method on the DonationLocationController

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            console.log('DonationLocationListHelper > getDonationLocations - getDonationLocations response: ' + response.getState())
            var state = response.getState();
            if (state === "SUCCESS") {

                // locationList
                var locationList = response.getReturnValue();
                //console.log('DonationLocationListHelper > getDonationLocations - locationList: ' + JSON.stringify(locationList));
                component.set("v.locationList", locationList);

                // map markers
                var mapMarkers = [];
                for (var i = 0; i < locationList.length; ++i) {

                    var location = locationList[i];
                    var title = location.Name;

                    if (location.Street_Address__c && location.City__c && location.State__c && location.Zip_Code__c) {

                        var address = location.Street_Address__c + ', ' + location.City__c + ', ' + location.State__c + ' ' + location.Zip_Code__c;
                        var description = address + '\n' + location.Website__c;

                        mapMarkers.push({
                            'location': {
                                'Street': location.Street_Address__c,
                                'City': location.City__c,
                                'State': location.State__c,
                                'PostalCode': location.Zip_Code__c
                            },
                            'icon': 'standard:location',
                            'title' : title,
                            'description' : description
                       });
                    }

                   component.set("v.mapMarkers", mapMarkers);
               }

            }
            else {
                console.log("DonationLocationListHelper > getDonationLocations - failed with state: " + state);
            }
        });

        // Send action off to be executed
        $A.enqueueAction(action);

    } // end getDonationLocations

})