@isTest
private class DateTimeFormatUtil_Test {

    @isTest static void test_formatDateTime() {
        
        String dateTimeString = null;
        
        DateTimeFormatUtil util = new DateTimeFormatUtil();
               
        // all parms
        util.dateTimeValue = DateTime.now();
        util.dateTimeFormat = 'EEE MMM d, yyyy hh:mm:ss a z';
        util.dateTimeZone = 'MDT'; // 'GMT-06:00';
        dateTimeString = util.getFormattedDateTime();
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (all parms MDT) dateTimeString: ' + dateTimeString);

        // time zone = PDT
        util.dateTimeZone = 'PDT'; // 'GMT-07:00';
        dateTimeString = util.getFormattedDateTime();
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no parms PDT) dateTimeString: ' + dateTimeString);

        // time zone = MST
        util.dateTimeZone = 'MST'; // 'GMT-07:00';
        dateTimeString = util.getFormattedDateTime();
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no parms MST) dateTimeString: ' + dateTimeString);

        // time zone = EDT
        util.dateTimeZone = 'EDT';
        dateTimeString = util.getFormattedDateTime();
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no parms EDT) dateTimeString: ' + dateTimeString);

        // time zone = CDT
        util.dateTimeZone = 'CDT';
        dateTimeString = util.getFormattedDateTime();
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no parms CDT) dateTimeString: ' + dateTimeString);
        
        // no timezone
        util.dateTimeZone = null;
        dateTimeString = util.getFormattedDateTime();        
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no timezone) dateTimeString: ' + dateTimeString);
       
        // test - no format
        util.dateTimeFormat = null;
        dateTimeString = util.getFormattedDateTime();        
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no format) dateTimeString: ' + dateTimeString);
        
        // test - no parms
        util.dateTimeValue = null;
        dateTimeString = util.getFormattedDateTime();
        System.debug('DateTimeFormatUtil_Test > test_formatDateTime - (no parms) dateTimeString: ' + dateTimeString);
        
        System.debug('DateTimeFormatUtil_Test > DateTimeForFilename: ' + DateTimeFormatUtil.getDateTimeForFilename());
        
        
    } // end test_formatDateTime
    
}