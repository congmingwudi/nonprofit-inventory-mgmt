public class DateTimeFormatUtil {

    public DateTime dateTimeValue { get; set; }
    public String dateTimeFormat { get; set; }
    public String dateTimeZone { get; set; }

    public String getFormattedDateTime() {
        return formatDateTime(dateTimeValue, dateTimeFormat, dateTimeZone);
    } // end format

    static String formatDateTime(DateTime value, String format, String timeZone) {
        System.debug('DateTimeFormatUtil > formatDateTime - value: ' + value + ', format: ' + format + ', timeZone: ' + timeZone);

        String dateTimeString;
        if (value == null) {
            dateTimeString = '';
        } else {
            if (format == null) {
                dateTimeString = value.format(); // return the full date/time in user's locale and time zone
            } else if (timeZone == null) {
                dateTimeString = value.format(format); // return formated date/time in user's locale and time zone
            } else {
                // fix support for daylight savings time
                timezone = daylightSavingsTimeGMT(timeZone);

                // format
                dateTimeString = value.format(format, timezone);  // specify time zone like IST, CST, MST

                // fix support for daylight savings time
                dateTimeString = daylightSavingsTimeZone(dateTimeString);
            }
        }

        return dateTimeString;

    } // end formatDateTime

    // provides support for daylight savings time, returns the GMT offset
    static String daylightSavingsTimeGMT(String timeZone) {

        String gmt = null;

        switch on timeZone {
            when 'EDT' {
                gmt = 'GMT-04:00';
            } // Eastern Daylight Time
            when 'CDT' {
                gmt = 'GMT-05:00';
            } // Central Daylight Time
            when 'MDT' {
                gmt = 'GMT-06:00';
            } // Mountain Daylight Time
            when 'PDT' {
                gmt = 'GMT-07:00';
            } // Pacific Daylight Time
            when else {
                gmt = timeZone;
            }
        }

        //System.debug('DateTimeFormatUtil > daylightSavingsTimeGMT - timeZone: ' + timeZone + ', gmt: ' + gmt);
        return gmt;

    } // end daylightSavingsTimeGMT

    // replaces date string GMT offset with daylight savings time zone
    static String daylightSavingsTimeZone(String dateString) {

        //System.debug('DateTimeFormatUtil > daylightSavingsTimeZone - dateString before: ' + dateString);

        if (dateString.contains('GMT-')) {

            Integer startIndex = dateString.indexOf('GMT-');
            Integer endIndex = startIndex + 9; // length of 'GMT-06:00'
            String gmt = dateString.substring(startIndex, endIndex);
            String timeZone = gmt;

            switch on gmt {
                when 'GMT-04:00' {
                    timeZone = 'EDT';
                } // Eastern Daylight Time
                when 'GMT-05:00' {
                    timeZone = 'CDT';
                } // Central Daylight Time
                when 'GMT-06:00' {
                    timeZone = 'MDT';
                } // Mountain Daylight Time
                when 'GMT-07:00' {
                    timeZone = 'PDT';
                } // Pacific Daylight Time
            }

            dateString = dateString.replace(gmt, timezone);

        } // end GMT-

        //System.debug('DateTimeFormatUtil > daylightSavingsTimeZone - dateString after: ' + dateString);
        return dateString;

    } // end daylightSavingsTimeGMT    

    public static String getDateTimeForFilename() {
        return System.now().format('yyyy-MM-dd\'T\'HH:mm');
    }


} // end DateTimeFormatUtil