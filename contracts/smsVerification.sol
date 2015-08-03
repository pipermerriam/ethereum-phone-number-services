//sol SMS Verification
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// SMS based phone number verification.
contract SMSVerification {
        // `owner` is the main phone number verification contract
        address owner;

        // Initializer
        function SMSVerification() {
            // Set the owner of the contract to be the creator of this
            owner = msg.sender;
        }

        // Management
        // TODO: What sort of management should go in place here.

        // Verification API
        function initiatePhoneNumberVerification(address operator, bytes32 phoneNumber) {
            // Dole out jobs to the relay contracts such that the `operator`
            // will get an SMS message that they can then report back.
        }

        function verifyPhoneNumber(bytes32 smsMessage) {
            // Remove a phone number to the database.
        }
}
