// Run this Anonymous Apex once (Dev Console: Execute Anonymous, or CLI: sfdx force:apex:execute -f scripts/apex/TokenUsageSchedule.apex)
// Schedules the TokenUsageHourlyScheduler to run every hour at the top of the hour.
// Uses the scheduleHourly helper method in the class to ensure the cron expression is centralized.
TokenUsageHourlyScheduler.scheduleHourly('TokenUsage Hourly');