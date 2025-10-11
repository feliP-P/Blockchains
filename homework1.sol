// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SendEther {
    address payable public recipient;
    address public owner; // <-- Declare owner

    constructor(address payable _recipient) {
        recipient = _recipient;
        owner = msg.sender; // <-- Set owner to deployer
    }

    function sendPayment() public payable {
        require(msg.value > 0, "Debes enviar ETH junto con la transaccion");
        recipient.transfer(msg.value);
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw"); // <-- Check owner
        payable(owner).transfer(address(this).balance); // <-- Send to owner
    }
}