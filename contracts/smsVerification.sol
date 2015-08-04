//sol SMS Verification
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// SMS based phone number verification.
contract SMSVerification {
        // `owner` is the main phone number verification contract
        address owner;
        address[] relays;

        //
        //  Constants
        //

        // Sentinal value for signaling that no relays are available.
        int const NO_RELAY_AVAILABLE = -1;

        // Messages are valid for 5 minutes (300 seconds).
        uint const MESSAGE_VALIDITY_SECONDS = 300;

        // The amount in wei that verification costs. 
        // TODO: figure out a real number for this.
        uint const VERIFICATION_DEPOSIT = 100000000000000

        // Sentinal value to signal that we do not have a record for this
        // operator.
        address const NO_OPERATOR_FOUND = 0x0;

        struct SMSMessage {
                bytes32 toNumber;
                address toOperator;
                bytes32 fromNumber;
                address fromOperator;
                bytes32 secret;
                uint createdAt;
                uint expiresAt;
                uint deposit;
        };

        struct Operator {
                address operator;
                uint createdAt;
                mapping (bytes32 => SMSMessage) smsMessages;
        };

        mapping (address => Operator) operators;

        // Initializer
        function SMSVerification() {
                // Set the owner of the contract to be the creator of this
                owner = msg.sender;
        }

        // Management
        // TODO: What sort of management should go in place here.


        // Private API
        function getRandomRelayIndex() private returns (int relayIndex) {
                if ( relays.length == 0 )
                        return NO_RELAY_AVAILABLE;
                for (var i = 0; i < relays.length; i++)
                {
                    // Pick a random relay using `block.blockhash()` as the random
                    // number generator.
                    int relayIndex = (block.blockhash() + i) % relays.length;

                    // Check whether the relay is willing to relay the message over SMS
                    if ( relays[relayIndex].willRelay() ) {
                        return relayIndex;
                    }
                }
                return NO_RELAY_AVAILABLE;
        }

        function getOperator(address _address) returns (Operator operator) {
                if ( operators[_address].operator == NO_OPERATOR_FOUND ) {
                    var operator = Operator(_address, msg.now);
                    return operator;
                }
                else {
                    return operators[_address];
                }
        }

        function generateSecret() returns (bytes32 secret) {
                // TODO: this should be returning a short, human readable
                // string rather than a sha3.  Figure out how to do this.
                return sha3(block.blockhash, msg.data);
        }

        //
        // Verification API
        //
        function initiateVerification(bytes32 phoneNumber) returns (SMSMessage smsMessage) {
                // Check that the message was paid for.
                if ( msg.value < VERIFICATION_DEPOSIT ) {
                    // fail: did not pay enough.
                }

                int relayIndex = getRandomRelay();

                // Check that there is a relay available.
                if ( relayIndex == NO_RELAY_AVAILABLE ) {
                    // fail: no relays available.
                }

                address relay = relays[relayIndex];

                bytes32 secret = generateSecret();

                var operator = getOperator(relay);

                var message = operator.smsMessage[secret];

                if (message.expiresAt == 0 || message.expiresAt > msg.now) {
                        // The message is either expired or new
                        uint expiresAt = msg.now + MESSAGE_VALIDITY_SECONDS;

                        message.toNumber = relay.phoneNumber();
                        message.toOperator = relay;
                        message.fromNumber = phoneNumber;
                        message.fromOperator = msg.sender;
                        message.secret = secret;
                        message.createdAt = msg.now;
                        message.expiresAt = expiresAt;
                        message.deposit = msg.value;
                }
                else {
                        // TODO: This case needs more careful consideration.  If
                        // this message already exists and is not expired we are
                        // likely experiencing a hash collision and should do
                        // something other than just add to the deposit.

                        // Keep track of the users deposit.
                        message.deposit += msg.value;
                }

                return message;
        }

        function reportMessage(bytes32 secret) {
                receivingOperator = getOperator(msg.sender);
                confirmedMessage = operator.smsMessage[secret]

                if (secret == confirmedMessage.secret) {
                        // YEAH! validated.
                }

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
