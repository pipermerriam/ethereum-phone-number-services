import "owned";


contract Relay is owned {
        address operator;

        bytes32[] secrets;
        uint secretIndex = 0;

        mapping (bytes32 => bytes32) hashes;

        modifier onlyoperator { if (msg.sender == operator) { _ }}

        function Relay() {
                operator = msg.sender;
        }

        function addSecret(bytes32 secretHash) {
            secrets.length += 1;
            secrets[secrets.length - 1] = secretHash;
        }

        function getNumSecrets() returns (uint) {
            return secrets.length - secretIndex;
        }

        function getLatestSecret(bool consume) returns (bytes32 secret) {
            if (secretIndex >= secrets.length) {
                return "";
            }
            secret = secrets[secretIndex];
            if (consume) {
                secretIndex += 1;
            }
            return secret;
        }
}
