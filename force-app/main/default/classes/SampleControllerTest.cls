/**
 * Test class for SampleController
 * Demonstrates various test coverage scenarios for GitHub Actions workflow
 */
@IsTest
public class SampleControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts with different revenue levels
        List<Account> testAccounts = new List<Account>();
        
        for (Integer i = 1; i <= 5; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                AnnualRevenue = 100000 * i,
                Type = 'Customer'
            ));
        }
        
        insert testAccounts;
    }
    
    @IsTest
    static void testGetWelcomeMessage_WithValidName() {
        // Test with valid user name
        Test.startTest();
        String result = SampleController.getWelcomeMessage('John Doe');
        Test.stopTest();
        
        Assert.areEqual('Welcome, John Doe!', result, 'Should return personalized welcome message');
    }
    
    @IsTest
    static void testGetWelcomeMessage_WithBlankName() {
        // Test with blank name
        Test.startTest();
        String result1 = SampleController.getWelcomeMessage('');
        String result2 = SampleController.getWelcomeMessage(null);
        Test.stopTest();
        
        Assert.areEqual('Welcome, Guest!', result1, 'Should return guest message for empty string');
        Assert.areEqual('Welcome, Guest!', result2, 'Should return guest message for null');
    }
    
    @IsTest
    static void testCalculateDiscount_PremiumCustomer() {
        Test.startTest();
        
        // Test premium customer with high order amount
        Decimal discount1 = SampleController.calculateDiscount(1500, 'Premium');
        Assert.areEqual(225.0, discount1, 'Premium customer with >1000 should get 15% discount');
        
        // Test premium customer with lower order amount
        Decimal discount2 = SampleController.calculateDiscount(800, 'premium');
        Assert.areEqual(80.0, discount2, 'Premium customer with <=1000 should get 10% discount');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCalculateDiscount_GoldCustomer() {
        Test.startTest();
        
        // Test gold customer with high order amount
        Decimal discount1 = SampleController.calculateDiscount(600, 'Gold');
        Assert.areEqual(72.0, discount1, 'Gold customer with >500 should get 12% discount');
        
        // Test gold customer with lower order amount
        Decimal discount2 = SampleController.calculateDiscount(400, 'GOLD');
        Assert.areEqual(32.0, discount2, 'Gold customer with <=500 should get 8% discount');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCalculateDiscount_SilverCustomer() {
        Test.startTest();
        
        Decimal discount = SampleController.calculateDiscount(1000, 'Silver');
        Assert.areEqual(50.0, discount, 'Silver customer should get 5% discount');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCalculateDiscount_StandardCustomer() {
        Test.startTest();
        
        // Test with explicit standard customer type
        Decimal discount1 = SampleController.calculateDiscount(1000, 'Standard');
        Assert.areEqual(20.0, discount1, 'Standard customer should get 2% discount');
        
        // Test with null customer type (defaults to standard)
        Decimal discount2 = SampleController.calculateDiscount(1000, null);
        Assert.areEqual(20.0, discount2, 'Null customer type should default to standard');
        
        // Test with unknown customer type
        Decimal discount3 = SampleController.calculateDiscount(1000, 'Unknown');
        Assert.areEqual(20.0, discount3, 'Unknown customer type should default to standard');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCalculateDiscount_InvalidInput() {
        Test.startTest();
        
        try {
            SampleController.calculateDiscount(0, 'Premium');
            Assert.fail('Should throw exception for zero amount');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('positive'), 'Should throw appropriate error message');
        }
        
        try {
            SampleController.calculateDiscount(-100, 'Premium');
            Assert.fail('Should throw exception for negative amount');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('positive'), 'Should throw appropriate error message');
        }
        
        try {
            SampleController.calculateDiscount(null, 'Premium');
            Assert.fail('Should throw exception for null amount');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('positive'), 'Should throw appropriate error message');
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetTopAccounts_ValidLimit() {
        Test.startTest();
        
        List<Account> accounts = SampleController.getTopAccounts(3);
        
        Test.stopTest();
        
        Assert.areEqual(3, accounts.size(), 'Should return requested number of accounts');
        
        // Verify accounts are ordered by revenue (descending)
        if (accounts.size() > 1) {
            Assert.isTrue(accounts[0].AnnualRevenue >= accounts[1].AnnualRevenue, 
                         'Accounts should be ordered by revenue descending');
        }
    }
    
    @IsTest
    static void testGetTopAccounts_InvalidLimit() {
        Test.startTest();
        
        List<Account> accounts1 = SampleController.getTopAccounts(0);
        List<Account> accounts2 = SampleController.getTopAccounts(-5);
        List<Account> accounts3 = SampleController.getTopAccounts(null);
        
        Test.stopTest();
        
        // All should default to 10 (or available count if less)
        Assert.isTrue(accounts1.size() <= 10, 'Should default to max 10 accounts');
        Assert.isTrue(accounts2.size() <= 10, 'Should default to max 10 accounts');
        Assert.isTrue(accounts3.size() <= 10, 'Should default to max 10 accounts');
    }
    
    @IsTest
    static void testProcessOrderStatus_PendingOrders() {
        Test.startTest();
        
        // Test urgent high-value order
        String status1 = SampleController.processOrderStatus('Pending', true, 15000);
        Assert.areEqual('Priority Processing', status1, 'Urgent high-value order should get priority processing');
        
        // Test non-urgent high-value order
        String status2 = SampleController.processOrderStatus('Pending', false, 8000);
        Assert.areEqual('Processing', status2, 'High-value order should get processing status');
        
        // Test low-value order
        String status3 = SampleController.processOrderStatus('Pending', false, 1000);
        Assert.areEqual('Standard Processing', status3, 'Low-value order should get standard processing');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessOrderStatus_BlankStatus() {
        Test.startTest();
        
        String status1 = SampleController.processOrderStatus('', true, 1000);
        String status2 = SampleController.processOrderStatus(null, false, 5000);
        
        Test.stopTest();
        
        Assert.areEqual('Draft', status1, 'Blank status should return Draft');
        Assert.areEqual('Draft', status2, 'Null status should return Draft');
    }
    
    @IsTest
    static void testComplexMethodWithLowCoverage_BasicScenario() {
        // This test only covers the basic scenario, leaving many branches uncovered
        // This is intentional to demonstrate low coverage reporting
        
        Test.startTest();
        
        SampleController.complexMethodWithLowCoverage('simple input');
        SampleController.complexMethodWithLowCoverage('');
        SampleController.complexMethodWithLowCoverage(null);
        
        Test.stopTest();
        
        // No assertions needed - this is just for coverage demonstration
        Assert.isTrue(true, 'Method executed without errors');
    }
    
    // Note: The following test methods are commented out to demonstrate
    // incomplete test coverage scenarios
    
    /*
    @IsTest
    static void testProcessOrderStatus_ProcessingOrders() {
        // This test is intentionally commented out to show missing coverage
        Test.startTest();
        
        String status1 = SampleController.processOrderStatus('Processing', false, 60000);
        Assert.areEqual('Executive Review', status1, 'Very high-value processing order should go to executive review');
        
        String status2 = SampleController.processOrderStatus('Priority Processing', false, 30000);
        Assert.areEqual('Ready for Shipment', status2, 'Processing order should be ready for shipment');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testComplexMethodWithLowCoverage_FullScenarios() {
        // This test would provide better coverage but is commented out
        Test.startTest();
        
        // Test long input scenario
        String longInput = 'This is a very long input string that contains more than 100 characters and should trigger the special processing logic for long strings with numbers like 123 and 456';
        SampleController.complexMethodWithLowCoverage(longInput);
        
        // Test special processing scenario
        SampleController.complexMethodWithLowCoverage('special processing required special handling');
        
        Test.stopTest();
    }
    */
}
