// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlip {
    
    uint public balance;
    uint public payout;
    uint private constant FEE = 5; // The game keeps 5% of your deposit as a fee
    address private owner;
    
    event GameResult(bool won, uint payout);
    
    constructor() {
        owner = msg.sender;
    }
    
    function flipCoin() public payable {
        require(msg.value > 0, "Must send some ether to play.");
        require(msg.value >= 1 ether, "Minimum bet is 1 ether.");
        require(balance >= 2* msg.value, "Insufficient balance");
        
        // Calculate payout
        payout = msg.value * 2;
        uint fee = msg.value / 100 * FEE;
        balance += fee;
        payout -= fee;
        
        // Flip the coin
        bool won = (block.timestamp % 2 == 0); // 50/50 chance of winning
        
        // Transfer payout to winner
        if (won) {
            payable(msg.sender).transfer(payout);
            balance -= msg.value;
        }
        
        emit GameResult(won, payout);
    }
    
    function depositBalance() public payable {
        require(msg.value > 0, "Cannot deposit 0 or negative value");
        require(msg.sender == owner, "Only the owner can deposit balance.");
        balance += msg.value;
    }

    function withdrawBalance() public {
        require(msg.sender == owner, "Only the owner can withdraw the balance.");
        payable(owner).transfer(balance);
        balance = 0;
    }
    
    function getBalance() public view returns (uint) {
        return balance;
    }
}
