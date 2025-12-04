@IsTest
private class ErrorLoggerTest {
    @IsTest
    static void testLogError_withSaveResult() {
        // Create a mock failed Database.SaveResult using JSON deserialization
        Database.SaveResult sr = (Database.SaveResult) JSON.deserialize('{"success":false,"errors":[{"message":"Simulated error","statusCode":"UNKNOWN_EXCEPTION"}]}', Database.SaveResult.class);
        
        Test.startTest();
        ErrorLogger.logError('TestJob', 'Test error message', sr);
        Test.stopTest();
        
        List<Error_Log__c> logs = [SELECT Id, Job_Name__c, Error_Message__c, Save_Result__c FROM Error_Log__c WHERE Job_Name__c = 'TestJob'];
        System.assertEquals(1, logs.size(), 'Should create exactly one error log');
        System.assertEquals('TestJob', logs[0].Job_Name__c, 'Job_Name__c should match');
        System.assertEquals('Test error message', logs[0].Error_Message__c, 'Error_Message__c should match');
        System.assertNotEquals(null, logs[0].Save_Result__c, 'Save_Result__c should not be null');
        System.assert(logs[0].Save_Result__c.contains('Simulated error'), 'Save_Result__c should contain serialized error details');
    }

    @IsTest
    static void testLogError_withNullSaveResult() {
        Test.startTest();
        ErrorLogger.logError('TestJobNull', 'Test error without SaveResult', null);
        Test.stopTest();
        
        List<Error_Log__c> logs = [SELECT Id, Job_Name__c, Error_Message__c, Save_Result__c FROM Error_Log__c WHERE Job_Name__c = 'TestJobNull'];
        System.assertEquals(1, logs.size(), 'Should create exactly one error log');
        System.assertEquals('TestJobNull', logs[0].Job_Name__c, 'Job_Name__c should match');
        System.assertEquals('Test error without SaveResult', logs[0].Error_Message__c, 'Error_Message__c should match');
        System.assertEquals(null, logs[0].Save_Result__c, 'Save_Result__c should be null');
    }

    @IsTest
    static void testLogError_multipleErrors() {
        Test.startTest();
        ErrorLogger.logError('Job1', 'Error 1', null);
        ErrorLogger.logError('Job2', 'Error 2', null);
        ErrorLogger.logError('Job3', 'Error 3', null);
        Test.stopTest();
        
        List<Error_Log__c> logs = [SELECT Id, Job_Name__c FROM Error_Log__c WHERE Job_Name__c IN ('Job1', 'Job2', 'Job3')];
        System.assertEquals(3, logs.size(), 'Should create three error logs');
        
        Set<String> jobNames = new Set<String>();
        for (Error_Log__c log : logs) {
            jobNames.add(log.Job_Name__c);
        }
        System.assert(jobNames.contains('Job1'), 'Logs should contain Job1');
        System.assert(jobNames.contains('Job2'), 'Logs should contain Job2');
        System.assert(jobNames.contains('Job3'), 'Logs should contain Job3');
    }
}