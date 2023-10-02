// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    
    address tokenAddress;
    
    constructor() ERC20("JUNG SWAP", "JUNG") {

    }

    //function addLiquidity() pulbic payable {}

    function removeLiquidity(uint lpTokenAmount) public {
        // (지분율) = (lpTokenAmount) / (전체 발행된 lpTokenAmount)
        //uint lpShares = lptokenAmount / balanceOf(address(this)); 
        // 정수인데, 지분율은 소수라 소수가 버려짐. 소수점은 uint로 저장하면 버려지게 된다.
        // lpShares는 언제나 0인 값이 나와버림. 반환 x

        _burn(msg.sender, lpTokenAmount);

        // 총 Ether의 갯수 * 지분율
        uint etherAmount = address(this).balance * lpTokenAmount / balanceOf(address(this));
        // 총 Token의 갯수 * 지분율

        ERC20 token = ERC20(tokenAddress);
        uint tokenAmount = token.balanceOf(address(this)) * lpTokenAmount / balanceOf(address(this));

        payable(msg.sender).transfer(etherAmount);
        token.transfer(msg.sender, tokenAmount);
    }


    function etherToTokenInput(uint minTokens) public payable {
        uint etherAmount = msg.value;
        ERC20 token = ERC20(tokenAddress);
        //address(this).balance --> 이렇게 하면 안된다. 유저가 가지고 있는 수량만큼 빼줘야 함
        //token.balanceOf(address(this))
        uint tokenAmount = getInputPrice(
            etherAmount, 
            address(this).balance - msg.value, 
            token.balanceOf(address(this))
        );
        require(tokenAmount >= minTokens);
        token.transfer(msg.sender, tokenAmount);

    }

    // getInputPrice == getOutputamount
    function getInputPrice(
        uint inputAmount, 
        uint inputReserve, 
        uint outputReserve
    ) public pure returns (uint outputAmount) {
        return inputAmount * 997 / 1000;
    }

    // getOutputPrice == getInputamount
    function getOutputPrice(
        uint outputAmount,
        uint inputReserve,
        uint outputReserve
    ) public pure returns (uint inputAmount) {
        return outputAmount / 997 * 1000; 
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