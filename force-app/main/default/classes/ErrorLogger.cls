public without sharing class ErrorLogger {
    /**
     * Logs an error to the Error_Log__c custom object.
     * @param jobName The name of the job or process where the error occurred.
     * @param errorMessage The main error message or exception message.
     * @param sr The Database.SaveResult object (optional), which will be serialized.
     */
    public static void logError(String jobName, String errorMessage, Database.SaveResult sr) {
        Error_Log__c log = new Error_Log__c();
        log.Job_Name__c = jobName;
        log.Error_Message__c = errorMessage;
        if (sr != null) {
            log.Save_Result__c = JSON.serialize(sr);
        }
        insert log;
    }
}