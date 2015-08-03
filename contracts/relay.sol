//sol SMS Relay
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// A utility contract that facilitates the sending of SMS messages.
contract SMSRelay {
        // `owner` is the main phone number verification contract
        address owner;
        // `operator` is the address of the ethereum account that is operating this
        // relay.
        address operator;
        // `phoneNumber` is the phone number that this relay will be using to send
        // SMS messages.
        bytes32 phoneNumber;

        // Initializer
        function SMSRelay(address operator, bytes32 phoneNumber) {
                // Set the owner of the contract to be the creator of this
                owner = msg.sender;
                operator = operator;
                phoneNumber = phoneNumber;
        }

        // Management
        function kill() {
                // `suicide` this contract and do something with the funds...
        }
        function withdraw() {
                // move some amount of the funds under this contract's control
                // to the `operator` address.
        }

        // Relay API
        function receivedSMS(bytes32 fromNumber, bytes32 smsMessage) {
                // Report the message to the owner contract via the `reportSMSReceipt`
                owner.reportSMSReceipt(fromNumber, smsMessage)
        }

        function sendSMS(bytes32 toNumber, bytes32 smsMessage) {
                // Queue a message to be sent.
                // TODO: how does this work.  Over whisper? or via an internal queue?
        }
}
