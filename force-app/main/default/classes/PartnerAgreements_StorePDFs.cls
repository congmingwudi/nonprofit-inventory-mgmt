/**
 * Created by ryan.cox on 2/12/20.
 */

global without sharing class PartnerAgreements_StorePDFs {

    static String bccEmail = 'ryan.cox@salesforce.com';
    static String emailTemplate_APPROVED = 'Partner_Signup_Approved';
    static String emailTemplate_RENEWED = 'Partner_Renewal_Submitted';

    @InvocableMethod(label='Partner Agreements Store PDFs')
    global static void partnerAgreementsStorePDFs(List<PartnerEventData> partnerEvents) {

        if (partnerEvents != null) {
            System.debug('PartnerAgreements_StorePDFs > partnerEvents: ' + partnerEvents.size());

            for (PartnerEventData eventData : partnerEvents) {

                System.debug('PartnerAgreements_StorePDFs > eventData: ' + eventData);
                String partnerID = eventData.partnerAccountID;
                String eventType = eventData.eventType; // APPROVED, RENEWED

                // get partner account
                Account partner = [SELECT Id, Name,
                        Latest_Partner_Agreement__c, Latest_Liability_Waiver__c,
                        Executive_Director__c, Executive_Director__r.Email,
                        npe01__One2OneContact__r.Email
                        FROM Account WHERE Id = :partnerID LIMIT 1];
                System.debug('PartnerAgreements_StorePDFs > partner: ' + partner);

                // agreements
                List<ID> partnerAgreementIDs = new List<ID>();
                partnerAgreementIDs.add(partner.Latest_Partner_Agreement__c);
                partnerAgreementIDs.add(partner.Latest_Liability_Waiver__c);

                // store agreement PDF files
                storePDFs(eventType, partner, partnerAgreementIDs);

            } // end for
        }

    } // end partnerAgreementsStorePDFs

    static void storePDFs(String eventType, Account partner, List<ID> partnerAgreementIDs) {

        System.debug('PartnerAgreements_StorePDFs > storePDFs - partnerAgreementIDs: ' + partnerAgreementIDs);

        // PDF page URL
        String siteURL = PartnerSignupController.getSiteURL();
        String pageURL = siteURL + Page.PartnerAgreementPDF.getUrl();
        System.debug('PartnerAgreements_StorePDFs > storePDFs - pageURL: ' + pageURL);

        // generate PDF content
        Map<ID, Blob> pdfMap = new Map<ID, Blob>();
        for (ID paID : partnerAgreementIDs) {
            Blob pdf = generatePDF(pageURL, paID);
            pdfMap.put(paID, pdf);
        }

        // get partner agreements
        Map<ID, Partner_Agreement__c> paMap = new Map<ID, Partner_Agreement__c>(
            [SELECT Id, Name, Partner__r.Name, Agreement_Type__c,
                    Partner_Executive_Director__r.Name, Partner_Executive_Director__r.Email
                FROM Partner_Agreement__c WHERE Id IN :partnerAgreementIDs] );
        System.debug('PartnerAgreements_StorePDFs > storePDFs - paMap: ' + paMap);

        // store PDF files
        List<ID> pasStored = new List<ID>();
        for (ID paID : partnerAgreementIDs) {
            Partner_Agreement__c pa = paMap.get(paID);
            Blob pdf = pdfMap.get(paID);
            Partner_Agreement__c paStored = storePDF(eventType, pa, pdf);
            if (paStored != null) {
                pasStored.add(paStored.Id);
                paMap.put(paID, paStored);
            }
        }
        System.debug('PartnerAgreements_StorePDFs > storePDFs - pdf files stored: ' + pasStored.size());

        // send email to partner w/ attached partner agreements
        sendEmail(eventType, partner, pasStored, paMap, pdfMap);

    } // end storePDFs

    static Blob generatePDF(String pageURL, String partnerAgreementID) {

        Blob pdf;
        try {
            // pdf page
            PageReference pdfPage = new PageReference(pageURL);
            pdfPage.getParameters().put('id', partnerAgreementID);
            System.debug('PartnerAgreements_StorePDFs > generatePDF - pdfPage: ' + pdfPage);

            // create pdf
            pdf = pdfPage.getContentAsPDF();
        }
        catch (Exception e) {
            System.debug('PartnerAgreements_StorePDFs > generatePDF - exception: ' + e);
        }
        return pdf;

    } // end generatePDF

    static Partner_Agreement__c storePDF(String eventType, Partner_Agreement__c pa, Blob pdf) {

        // store file associated with the partner agreement record

        try {
            // filename
            String fileName = PartnerSignupController.getPartnerAgreementFilename(pa); // requires Partner_Agreement__c fields: Agreement_Type__c, Partner__r.Name
            System.debug('PartnerAgreements_StorePDFs > storePDF - fileName: ' + fileName);

            String fileURL = PartnerSignupController.insertFile(pa.Id, fileName, pdf);

            // set shared link in the partner agreement
            pa.PDF_File_Name__c = fileName;
            pa.Shared_PDF_URL__c = fileURL;
            if (eventType == 'RENEWED') {
                pa.Status__c = 'Completed';
            }
            update pa;
            System.debug('PartnerAgreements_StorePDFs > storePDF - partner agreement updated: ' + pa);

        } catch (Exception e) {
            System.debug('PartnerAgreements_StorePDFs > storePDF - exception: ' + e);
            pa = null;
        }

        return pa;

    } // end storePDF

    static void sendEmail(String eventType, Account partner, List<ID> pasStored, Map<ID, Partner_Agreement__c> paMap, Map<ID, Blob> pdfMap) {

        System.debug('PartnerAgreements_StorePDFs > sendEmail - eventType: ' + eventType);

        // template
        String emailTemplateName;
        switch on eventType {
            when 'APPROVED' { emailTemplateName = emailTemplate_APPROVED; }
            when 'RENEWED' { emailTemplateName = emailTemplate_RENEWED; }
        }
        System.debug('PartnerAgreements_StorePDFs > sendEmail - emailTemplateName: ' + emailTemplateName);

        if (emailTemplateName != null) {

            // Create email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            // to email address
            String execEmail = partner.Executive_Director__r.Email;
            String primaryEmail = partner.npe01__One2OneContact__r.Email;
            message.setToAddresses(new String[]{ execEmail });
            message.setCcAddresses(new String[]{ primaryEmail });
            message.setBccAddresses(new String[]{ bccEmail });

            // activity
            message.setTargetObjectId(partner.Executive_Director__c);
            message.setSaveAsActivity(true);

            // email template
            ID emailTemplateID = PartnerSignupController.getEmailTemplateID(emailTemplateName);
            if (emailTemplateID != null) {
                message.setTemplateID(emailTemplateID);
                message.setWhatId(partner.Id);

                // from email address from Org Wide Email
                ID emailID = PartnerSignupController.getOrgWideEmailID();
                if (emailID != null) {
                    message.setOrgWideEmailAddressId(emailID);
                    message.setUseSignature(false); // removes org-wide user's email signature
                } // otherwise email will be sent from current user

                // attach PDFs to email
                Messaging.EmailFileAttachment[] attachments = new Messaging.EmailFileAttachment[]{};

                for (ID paID : pasStored) {
                    Partner_Agreement__c pa = paMap.get(paID);
                    Blob pdf = pdfMap.get(paID);

                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setContentType('application/pdf');
                    attachment.setFileName(pa.PDF_File_Name__c);
                    attachment.setInline(false);
                    attachment.setBody(pdf);
                    attachments.add(attachment);
                }
                message.setFileAttachments(attachments);

                // send email
                System.debug('PartnerAgreements_StorePDFs > sendEmail - email message: ' + message);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
                System.debug('PartnerAgreements_StorePDFs > sendEmail - results: ' + results);

            } else {
                System.debug('PartnerAgreements_StorePDFs > sendEmail - email not sent; missing email template.');
            }

        } // end emailTemplateName != null

    } // end sendEmail


} // end PartnerAgreements_StorePDFs