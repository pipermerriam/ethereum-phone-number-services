import "owned";

contract Relay {
        function getNumSecrets() returns (uint) {}
        function getLatestSecret(bool consume) returns (bytes32) {}
}


contract SMSVerifier is owned {
        address[] relays;

        function SMSVerifier(address genesisRelay) {
                relays.length += 1;
                relays[0] = genesisRelay;
        }

        function getRandomRelay() internal returns (address) {
                uint i = uint(block.blockhash(block.number)) % relays.length;
                return relays[i];
        }

        struct Verification {
                bytes32 phoneNumber;
                address relay;
                bytes32 relaySecret;
                uint relayDeposit;
        }
        Verification[] verifications;

        function initiateVerification(bytes32 phoneNumber, address operator) {
                address relay = getRandomRelay();
        }
}
