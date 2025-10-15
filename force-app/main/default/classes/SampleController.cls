/**
 * Sample Apex Controller for testing GitHub Actions workflow
 * This class demonstrates various scenarios for code coverage testing
 */
public with sharing class SampleController {
    
    /**
     * Simple method that should have good test coverage
     */
    public static String getWelcomeMessage(String userName) {
        if (String.isBlank(userName)) {
            return 'Welcome, Guest!';
        }
        return 'Welcome, ' + userName + '!';
    }
    
    /**
     * Method with business logic that needs comprehensive testing
     */
    public static Decimal calculateDiscount(Decimal orderAmount, String customerType) {
        if (orderAmount == null || orderAmount <= 0) {
            throw new IllegalArgumentException('Order amount must be positive');
        }
        
        if (String.isBlank(customerType)) {
            customerType = 'Standard';
        }
        
        Decimal discountRate = 0;
        
        switch on customerType.toLowerCase() {
            when 'premium' {
                discountRate = orderAmount > 1000 ? 0.15 : 0.10;
            }
            when 'gold' {
                discountRate = orderAmount > 500 ? 0.12 : 0.08;
            }
            when 'silver' {
                discountRate = 0.05;
            }
            when else {
                discountRate = 0.02;
            }
        }
        
        return orderAmount * discountRate;
    }
    
    /**
     * Method that demonstrates database operations
     */
    public static List<Account> getTopAccounts(Integer limitCount) {
        if (limitCount == null || limitCount <= 0) {
            limitCount = 10;
        }
        
        try {
            return [
                SELECT Id, Name, AnnualRevenue, Type 
                FROM Account 
                WHERE AnnualRevenue != null 
                ORDER BY AnnualRevenue DESC 
                LIMIT :limitCount
            ];
        } catch (Exception e) {
            System.debug('Error retrieving accounts: ' + e.getMessage());
            return new List<Account>();
        }
    }
    
    /**
     * Method with complex logic that might have coverage gaps
     */
    public static String processOrderStatus(String currentStatus, Boolean isUrgent, Decimal orderValue) {
        String newStatus = currentStatus;
        
        if (String.isBlank(currentStatus)) {
            return 'Draft';
        }
        
        // This complex logic might not be fully covered in tests
        if (currentStatus.equals('Pending')) {
            if (isUrgent && orderValue > 10000) {
                newStatus = 'Priority Processing';
            } else if (orderValue > 5000) {
                newStatus = 'Processing';
            } else {
                newStatus = 'Standard Processing';
            }
        } else if (currentStatus.equals('Processing') || currentStatus.equals('Priority Processing')) {
            // This branch might be missed in testing
            if (orderValue > 50000) {
                newStatus = 'Executive Review';
            } else {
                newStatus = 'Ready for Shipment';
            }
        }
        
        return newStatus;
    }
    
    /**
     * Method that intentionally has low coverage for demonstration
     */
    public static void complexMethodWithLowCoverage(String input) {
        if (String.isBlank(input)) {
            System.debug('Input is blank');
            return;
        }
        
        // These branches are intentionally not covered in the test class
        if (input.length() > 100) {
            System.debug('Very long input');
            // Complex processing logic here
            for (Integer i = 0; i < input.length(); i++) {
                if (input.substring(i, i+1).isNumeric()) {
                    System.debug('Found number at position: ' + i);
                }
            }
        } else if (input.contains('special')) {
            System.debug('Special processing required');
            // More complex logic
            String[] parts = input.split(' ');
            for (String part : parts) {
                if (part.startsWith('special')) {
                    System.debug('Processing special part: ' + part);
                }
            }
        }
        
        // This will never be covered
        if (input.equals('impossible_value_that_never_occurs')) {
            System.debug('This should never happen');
        }
    }
}
