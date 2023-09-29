// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Factory
// - Product(v1 : Exchange, v2 : Pair)


contract Exchange {
    uint public number;
    constructor(uint _number) {
        number = _number;
    }
}

contract Factory {
    //address is number 쉽게 하기 위해서.
    mapping(uint => address) public numberToExchange; // token주소를 통한 exchange 주소 찾기
    mapping(address => uint) public exchangeToNumber; // exchange주소를 통한 token 주소 찾기


    function createExchange(uint number) public returns(address) {
        Exchange created = new Exchange(number); // --> 새로운 컨트랙트 생성하기 문법
        //Exchange created = Exchange(number); --> 이미 배포된거에서 호출하기 문법
        
        numberToExchange[number] = address(created);
        exchangeToNumber[address(created)] = number;
        return address(created);

    }
}
