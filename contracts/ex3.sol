// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// A Token 만들기

contract TokenA is ERC20 {
    constructor() ERC20("TokenA","A") {

    }
}

// etherToTokenSwap
contract JungSwap {
    // Ether <> A Token Exchange
    // 그러므로 해당 토큰 address를 가지고 있어야 한다.
    address tokenAddress;

    function etherToTokenSwap() public payable returns(bool) {
        uint etherAmount = msg.value;
        // CSMM: etherAmount + tokenAmount = k
        uint tokenAmount = etherAmount;
        // 토큰 주는 행위가 필요하다.
        TokenA tokenContract = TokenA(tokenAddress);
        tokenContract.transfer(msg.sender, tokenAmount);
        return true;
    }

    function tokenToEtherSwap(uint tokenAmount) public returns(bool) {
        // uint tokenAmount = amount;
        // uint etherAmount = tokenAmount;
        // TokenA tokenContract = TokenA(tokenAddress);
        // tokenContract.transfer(address(this), amount);
        // payable(msg.sender).transfer(etherAmount);
        // 이 컨트랙트 주소가 owner가 아니니, 남의 돈을 빼올 수 없다.
        
        // 사용자는 token <> Ether일때 두번 호출한다.
        // Approve()는 별도의 tx로 진행된 상태
        TokenA tokenContract = TokenA(tokenAddress);
        tokenContract.transferFrom(msg.sender, address(this), tokenAmount);
        uint etherAmount = tokenAmount;
        payable(msg.sender).transfer(etherAmount);

        return true;
    }

}