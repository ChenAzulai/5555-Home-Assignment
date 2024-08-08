public with sharing class SalesmanController {
    public static final String SALES_PROFILE_NAME = 'Custom: Sales Profile';

    @AuraEnabled(cacheable=true)
    public static List<User> getSalesUsers() {
        // Fetch users with profile 'Custom: Sales Profile'
        return [SELECT Id, Name FROM User WHERE Profile.Name = :SALES_PROFILE_NAME];
    }

    @AuraEnabled(cacheable=false)
    public static List<AggregateResult> getMonthlySalesData(Id userId) {
        // Define the start date as 12 months ago
        Date twelveMonthsAgo = System.today().addMonths(-12);
    
        // Query to get total sales amount grouped by month
        return [
            SELECT CALENDAR_MONTH(SaleDate__c) month,
                   CALENDAR_YEAR(SaleDate__c) year,
                   SUM(Amount__c) totalSales
            FROM SalesRecord__c
            WHERE OwnerId = :userId
              AND SaleDate__c >= :twelveMonthsAgo
            GROUP BY CALENDAR_MONTH(SaleDate__c), CALENDAR_YEAR(SaleDate__c)
            ORDER BY CALENDAR_YEAR(SaleDate__c), CALENDAR_MONTH(SaleDate__c)
        ];
    }
}