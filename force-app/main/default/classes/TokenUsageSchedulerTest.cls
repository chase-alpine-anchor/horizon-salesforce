@IsTest
private class TokenUsageSchedulerTest {
    @IsTest
    static void publishOnce_succeeds() {
        Test.startTest();
        Database.SaveResult sr = TokenUsageHourlyScheduler.publishOnce();
        Test.stopTest();
        System.assertNotEquals(null, sr, 'SaveResult should not be null');
        System.assertEquals(true, sr.isSuccess(), 'Platform event should publish successfully');
    }

    @IsTest
    static void scheduled_executes() {
        Test.startTest();
        // Schedule to a far-future single-fire time; stopTest will execute it once in tests
        String jobId = System.schedule('TokenUsage Hourly Test', '0 0 0 1 1 ? 2030', new TokenUsageHourlyScheduler());
        System.assertNotEquals(null, jobId, 'Scheduled job Id should be returned');
        Test.stopTest(); // Triggers execute() of the scheduled class
    }

    @IsTest
    static void scheduleHourly_customName_setsCronAndName() {
        Test.startTest();
        String customName = 'TokenUsage Hourly Custom Test';
        Id jobId = TokenUsageHourlyScheduler.scheduleHourly(customName);
        System.assertNotEquals(null, jobId, 'Scheduled job Id should be returned');

        // Verify CronTrigger details
        CronTrigger ct = [
            SELECT Id, CronExpression, State, TimesTriggered, CronJobDetail.Name
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];
        System.assertEquals(customName, ct.CronJobDetail.Name, 'Job name should match custom name');
        System.assertEquals('0 0 0/1 * * ?', ct.CronExpression, 'Cron expression should be hourly on the hour');
        Test.stopTest();
    }

    @IsTest
    static void scheduleHourly_blankOrNullName_defaultsToTokenUsageHourly() {
        Test.startTest();
        // String.isBlank handles both null and empty string, so we test one representative case
        // to avoid "Job already scheduled" errors if multiple tests try to schedule the same default name
        Id jobId = TokenUsageHourlyScheduler.scheduleHourly('');
        System.assertNotEquals(null, jobId, 'Scheduled job Id should be returned');

        CronTrigger ct = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];
        System.assertEquals('TokenUsage Hourly', ct.CronJobDetail.Name, 'Default job name should be used when blank provided');
        Test.stopTest();
    }

    @IsTest
    static void execute_handlesPublishFailure() {
        // Create a test scenario where publishOnce fails via SaveResult
        TokenUsageHourlyScheduler.forceSaveResultFailure = true;
        
        Test.startTest();
        TokenUsageHourlyScheduler scheduler = new TokenUsageHourlyScheduler();
        
        // Execute the scheduler - this should handle any potential errors gracefully
        System.SchedulableContext mockContext = null;
        scheduler.execute(mockContext);
        Test.stopTest();

        List<Error_Log__c> logs = [SELECT Id, Job_Name__c, Error_Message__c, Save_Result__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'Should create one error log');
        System.assertEquals('TokenUsageHourlyScheduler', logs[0].Job_Name__c);
        System.assert(logs[0].Error_Message__c.contains('Failed to publish'), 'Error message should indicate failure');
        System.assertNotEquals(null, logs[0].Save_Result__c, 'SaveResult should be logged');
    }

    @IsTest
    static void execute_handlesException() {
        // Create a test scenario where publishOnce throws exception
        TokenUsageHourlyScheduler.forceException = true;
        
        Test.startTest();
        TokenUsageHourlyScheduler scheduler = new TokenUsageHourlyScheduler();
        scheduler.execute(null);
        Test.stopTest();
        
        List<Error_Log__c> logs = [SELECT Id, Job_Name__c, Error_Message__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'Should create one error log');
        System.assertEquals('TokenUsageHourlyScheduler', logs[0].Job_Name__c);
        System.assert(logs[0].Error_Message__c.contains('Simulated Exception'), 'Error message should match exception');
    }


}