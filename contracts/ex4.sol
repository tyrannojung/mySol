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


}