@IsTest
public class SalesmanControllerTest {

    @IsTest
    static void testGetSalesUsers() {
        // Query existing users with the 'Custom: Sales Profile'
        List<User> existingUsers = [
            SELECT Id, Name, Profile.Name
            FROM User
            WHERE Profile.Name = 'Custom: Sales Profile'
            LIMIT 1
        ];
        
        // If there are no existing users, the test cannot proceed, so we assert false
        System.assert(existingUsers.size() > 0, 'No users found with the Custom: Sales Profile profile.');

        // Call the method being tested
        List<User> users = SalesmanController.getSalesUsers();

        Set<String> existingUserNames = new Set<String>();
        Set<String> resultUserNames = new Set<String>();

        for (User u : existingUsers) {
            existingUserNames.add(u.Name);
        }

        for (User u : users) {
            resultUserNames.add(u.Name);
        }
        
        
        // Assert that the method returns users with the correct profile
        System.assertEquals(existingUsers.size(), users.size(), 'The number of users returned should match the number of existing users with the Custom: Sales Profile profile.');
        System.assertEquals(existingUserNames, resultUserNames, 'The user names from the database and the method result should match.');
        
    }


    @isTest
    static void testGetMonthlySalesData() {
        // Create a test user
        User testUser = new User(
            Username = 'someuser1@example.com',
            Alias = 'tuser',
            Email = 'someuser1@example.com',
            ProfileId = UserInfo.getProfileId(),
            UserRoleId = null,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'Test',
            IsActive = true
        );
        insert testUser;


        // Define the start date as 12 months ago
        Date twelveMonthsAgo = System.today().addMonths(-12);

        // Create test sales records
        List<SalesRecord__c> testRecords = new List<SalesRecord__c>{
            new SalesRecord__c(SaleDate__c = twelveMonthsAgo, Amount__c = 200, OwnerId = testUser.Id),
            new SalesRecord__c(SaleDate__c = System.today(), Amount__c = 300, OwnerId = testUser.Id)
        };
        insert testRecords;

        // Call the method
        List<AggregateResult> results = SalesmanController.getMonthlySalesData(testUser.Id);

        // Assert the results
        System.assertEquals(2, results.size(), 'Expected 2 results');
        
    }
}