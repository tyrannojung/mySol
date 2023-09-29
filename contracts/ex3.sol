// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// A Token 만들기

contract TokenA is ERC20 {
    constructor() ERC20("TokenA","A") {

    }
}

// etherToTokenSwap
contract JungSwap is ERC20 {
    // Ether <> A Token Exchange
    // 그러므로 해당 토큰 address를 가지고 있어야 한다.
    address public tokenAddress;

    constructor(address _tokenAddress) ERC20("JungLP", "JUNG") {
        tokenAddress = _tokenAddress;
    }

    function addLiquidity() public payable returns (bool) {
        // LP공급자로 부터 Ether와 Token을 받는다. (1, 1) = 1 LP
        // LP공급자에게 받은 만큼 LP Token을 민팅한다.
        
        // a token b token 1 : 1 비율로 입금
        uint etherAmount = msg.value;
        uint tokenAmount = etherAmount;
        TokenA tokenContract = TokenA(tokenAddress);
        // Approve()는 별도의 tx로 진행된 상태
        tokenContract.transferFrom(msg.sender, address(this), tokenAmount);
        _mint(msg.sender, etherAmount);
        return true;
    }

    function removeLiquidity(uint lpTokenAmount) public returns(bool) {
        // require(balances[msg.sender] >= lpTokenAmount);
        // TokenA tokenContract = TokenA(tokenAddress);
        // tokenContract.transfer(msg.sender, tokenAmount);
        // payable(msg.sender).transfer(tokenAmount);
        _burn(msg.sender, lpTokenAmount);
        uint etherAmount = lpTokenAmount;
        uint tokenAmount = lpTokenAmount;
        payable(msg.sender).transfer(etherAmount);
        TokenA tokenContract = TokenA(tokenAddress);
        tokenContract.transfer(msg.sender, tokenAmount);
        return true;
    }

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