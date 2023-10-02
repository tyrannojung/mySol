// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    
    address tokenAddress;
    
    constructor() ERC20("JUNG SWAP", "JUNG") {

    }

    function etherToTokenInput(uint minTokens) public payable {
        uint etherAmount = msg.value;
        uint tokenAmount = etherAmount * 997 / 1000;
        require(tokenAmount >= minTokens);
        ERC20 token = ERC20(tokenAddress);
        token.transfer(msg.sender, tokenAmount);

    }

    // getInputPrice == getOutputamount
    function getInputPrice(
        uint inputAmount, 
        uint inputReserve, 
        uint outputReserve
    ) public pure returns (uint outputAmount) {

    }

    // getInputPrice == getOutputamount
    function getOutputPrice(
        uint outputAmount,
        uint inputReserve,
        uint outputReserve
    ) public pure returns (uint inputAmount) {

    }

    function etherToTokenOutput(uint tokenAmount, uint maxEtherAmount) public payable {
        // Token의 갯수가 고정 : Input parameter
        // MEV Attack
        uint etherAmount = tokenAmount / 997 * 1000;
        // Price Discovery Function
        // (X,Y), (x,y)
        // (1000, 1500), (100, y) ?
        // (1000, 1500), (x, 100) ?


        // 정확하게 필요한 ETH 수량 <> 유저가 낸 Ether(msg.value)
        require(maxEtherAmount >= etherAmount);
        require(msg.value >= etherAmount);
        uint etherRefundAmount = msg.value - etherAmount;
        if (etherRefundAmount > 0) {
            payable(msg.sender).transfer(etherRefundAmount);
        }
        ERC20 token = ERC20(tokenAddress);
        token.transfer(msg.sender, tokenAmount); 
    }

}