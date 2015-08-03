//sol Phone Number Database
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// A contract that stores a many-to-many relationship between phone numbers and
// addresses that are verified operators of that phone number.
contract PhoneNumberDatabase {
        // `owner` is the main phone number verification contract
        address owner;

        // Initializer
        function PhoneNumberDatabase() {
            // Set the owner of the contract to be the creator of this
            // TODO: this should create the initial smsVerification contract.
            owner = msg.sender;
        }

        // Management
        // TODO: What sort of management should go in place here.
        // - need a way to point at a new smsVerification contract.

        // Database API
        function add(address operator, bytes32 phoneNumber) {
            // Add a phone number to the database.
        }

        function remove(address operator, bytes32 phoneNumber) {
            // Remove a phone number to the database.
        }

        function check(address operator, bytes32 phoneNumber) {
            // Lookup whether the operator is verified with the given phone
            // number.
        }
}
