//sol SMS Verification
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// SMS based phone number verification.
contract SMSVerification {
        // `owner` is the main phone number verification contract
        address owner;
        address[] relays;
        int const NO_RELAY_AVAILABLE = -1;

        struct SMSMessage {
            bytes32 phoneNumber;
            bytes32 message;
        }

        // Initializer
        function SMSVerification() {
            // Set the owner of the contract to be the creator of this
            owner = msg.sender;
        }

        // Management
        // TODO: What sort of management should go in place here.


        // Private API
        function getRandomRelayIndex() private returns (int relayIndex) {
            // TODO: sanity check there are any relays at all
            for (var i = 0; i < relays.length; i++)
            {
                // Pick a random relay using `block.blockhash()` as the random
                // number generator.
                int relayIndex = (block.blockhash() + i) % relays.length;

                // Check whether the relay is willing to relay the message over SMS
                if ( relays[relayIndex].is_willing_to_relay )
                    return relayIndex;
            }
            return NO_RELAY_AVAILABLE;
        }

        // Verification API
        function initiateVerification(address operator, bytes32 phoneNumber) returns (SMSMessage smsMessage) {
            int relayIndex = getRandomRelay();

            if ( relayIndex == NO_RELAY_AVAILABLE )
                // fail!

            address relay = relays[relayIndex];

            // TODO: How do we generate the message.
            // TODO: the message needs to be stored somewhere it can easily be
            // looked up later and related to the current phone number being verified.
            bytes32 message = ;

            // TODO: store the `phoneNumber` and `operator` somewhere.

            return SMSMessage(relay.phoneNumber(), message);
        }

        function reportMessage(bytes32 smsMessage) {
            // TODO: how do we check for a message's validity.
            bool is_message_valid = ...;

            if ( is_message_valid )
                // TODO: lookup the appropriate relay.
                address relay = ....;
                // TODO: lookup the phone number being verified.
                bytes32 phoneNumber = ...;
                // TODO: how do we generate messages...
                bytes32 message = ...;

                relay.sendSMS(phoneNumber, message);
            else:
                // Fail?
        }
}
