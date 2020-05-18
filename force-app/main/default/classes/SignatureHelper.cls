public with sharing class SignatureHelper {

    @AuraEnabled
    public static void saveSign(String strSignElement, Id recId){

        System.debug('SignatureHelper > saveSign - record ID: ' + recId);
        System.debug('SignatureHelper > saveSign - strSignElement: ' + strSignElement);
        //String fileName = 'Signature_' + System.now() + '.png';

        String objectName = recId.getSObjectType().getDescribe().getName();
        System.debug('SignatureHelper > saveSign - objectName: ' + objectName);
        User user;
        if (objectName == 'User') {
            List<User> users = [SELECT Id, Name FROM User WHERE Id = :recId LIMIT 1];
            if (users.size() > 0) {
                user = users.get(0);
                //fileName = user.Name + '_User_' + fileName;
            } else {
                System.debug('SignatureHelper > saveSign - user not found with record ID: ' + recId);
            }
        }
        //else if (objectName == 'Partner_Agreement__c') {
        //    fileName = 'PartnerAgreement_' + fileName;
        //}
        //System.debug('SignatureHelper > saveSign - fileName: ' + fileName);

        /**
         * skip inserting signature in a file.
         * not needed anymore, because inserting into a rich text field instead.

        // create Salesforce File

        // insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName; //File name with extention
        cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach.OwnerId; //Owner of the file
        cVersion.Title = fileName; //Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(strSignElement); //File content
        insert cVersion;
        System.debug('SignatureHelper > saveSign - contentVersion inserted: ' + cVersion);

        */

        if (objectName == 'User') {
            // save in Signature__c rich text field of the User object
            if (user != null) {
                // convert image data to format required for rich text field
                // format is: <img alt="<image_Name>" src="data:image/<image_File_Extension>;base64, <base64_Image_String>"></img>
                String imageData = '<img alt=\"signature\" src=\"data:image/png;base64,' + strSignElement + '\"></img>';
                user.Signature__c = imageData;
                update user;
                System.debug('SignatureHelper > saveSign - image inserted into user signature: ' + user.Name);
            }
        }

        if (objectName == 'Partner_Agreement__c') {

            /**
             * skip inserting signature in a file.
             * not needed anymore, because inserting into a rich text field instead.

            // get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

            // insert ContentDocumentLink - only for Partner Agreement signatures
            // no need to insert document link for a user record signature,
            // because a link will automatically be created if performed by that user
            // which is the case when a user enters a signature from their profile page
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument; //Add ContentDocumentId
            cDocLink.LinkedEntityId = recId; //Add attachment parentId
            cDocLink.ShareType = 'I'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers'; //AllUsers, InternalUsers, SharedUsers
            insert cDocLink;
            System.debug('SignatureHelper > saveSign - ContentDocumentLink inserted: ' + cDocLink);

            */

            // save in Signature__c rich text field of the Partner_Agreement__c object
            List<Partner_Agreement__c> pas = [SELECT Id, Name, Signature__c FROM Partner_Agreement__c WHERE Id = :recId LIMIT 1];
            if (pas.size() > 0) {
                Partner_Agreement__c pa = pas.get(0);

                // convert image data to format required for rich text field
                // format is: <img alt="<image_Name>" src="data:image/<image_File_Extension>;base64, <base64_Image_String>"></img>
                String imageData = '<img alt=\"signature\" src=\"data:image/png;base64,' + strSignElement + '\"></img>';

                // update partner agreement
                pa.Signature__c = imageData;
                update pa;
                System.debug('SignatureHelper > saveSign - image inserted into partner agreement: ' + pa.Name);

            } else {
                System.debug('SignatureHelper > saveSign - partner agreement not found with record ID: ' + recId);
            }
        }

    } // end saveSign
}