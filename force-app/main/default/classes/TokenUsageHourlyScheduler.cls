public without sharing class TokenUsageHourlyScheduler implements System.Schedulable {
    
    @TestVisible
    private static Boolean forceException = false;
    @TestVisible
    private static Boolean forceSaveResultFailure = false;

    /**
     * Publishes the platform event Token_Usage_Token_Transaction_Parenting__e once.
     * No fields are populated as requested.
     */
    public static Database.SaveResult publishOnce() {
        if (Test.isRunningTest()) {
            if (forceException) {
                throw new CalloutException('Simulated Exception');
            }
            if (forceSaveResultFailure) {
                return (Database.SaveResult) JSON.deserialize('{"success":false,"errors":[{"message":"Simulated error","statusCode":"UNKNOWN_EXCEPTION"}]}', Database.SaveResult.class);
            }
        }
        Token_Usage_Token_Transaction_Parenting__e evt = new Token_Usage_Token_Transaction_Parenting__e();
        return EventBus.publish(evt);
    }

    /**
     * Schedulable entrypoint. Invoked by Salesforce scheduler.
     */
    public void execute(System.SchedulableContext sc) {
        try {
            Database.SaveResult sr = publishOnce();
            if (!sr.isSuccess()) {
                System.debug(LoggingLevel.ERROR, 'Failed to publish Token_Usage_Token_Transaction_Parenting__e: ' + sr);
                ErrorLogger.logError('TokenUsageHourlyScheduler', 'Failed to publish Token_Usage_Token_Transaction_Parenting__e', sr);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception publishing Token_Usage_Token_Transaction_Parenting__e: ' + e.getMessage());
            ErrorLogger.logError('TokenUsageHourlyScheduler', 'Exception publishing Token_Usage_Token_Transaction_Parenting__e: ' + e.getMessage(), null);
        }
    }

    /**
     * Helper to schedule this job hourly via code.
     * CRON: second minute hour dayOfMonth month dayOfWeek
     * "0 0 0/1 * * ?" = every hour at minute 0, second 0.
     */
    public static Id scheduleHourly(String jobName) {
        String cron = '0 0 0/1 * * ?';
        return System.schedule(String.isBlank(jobName) ? 'TokenUsage Hourly' : jobName, cron, new TokenUsageHourlyScheduler());
    }
}