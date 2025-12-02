// Run once to publish a single Token_Usage_Token_Transaction_Parenting__e event
Database.SaveResult result = TokenUsageHourlyScheduler.publishOnce();
System.debug('Platform event published. Success: ' + result.isSuccess());
if (!result.isSuccess()) {
    System.debug('Error: ' + result.getErrors());
}