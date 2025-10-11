// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SendEther {
    // Función para enviar ETH a cualquier dirección
    function sendPayment(address payable recipient) public payable {
        require(msg.value > 0, "Debes enviar ETH");
        recipient.transfer(msg.value);
    }
}
