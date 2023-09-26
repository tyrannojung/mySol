// SPDX-License-Identifier: onther
pragma solidity ^0.8.19;

contract Ownable {
    address public owner;
        
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner!");
        _;
    } 

    modifier costs(uint amount) {
        require(msg.value >= amount * 1 ether);
        _;
    }
}

contract Counter is Ownable {
    uint private value = 0;

    event Reset(address owner, uint currentValue);

    mapping(address => bool) blacklist;
    mapping(address => uint) balances; // 주소에 숫자 맵핑 대표적으로 토큰의 갯수 value표현
    mapping(address => mapping(address => uint)) a; // a라는 주소를 찾아갔다가 b라는 주소를통해 찾아가는것. (approve를 얼마나 했는가)
    // EOA Address -> Uniswap Exchange CA -> 1,000 개만큼 사용하도록 승인해줬다.

    function setBlackList(address _address) public {
        blacklist[_address] = true;
    }

    function getValue() public view returns (uint) {
        return value;
    }

    function increment() public payable costs(1) {
        value = value + 1;
    }

    function reset() public onlyOwner {
        emit Reset(msg.sender, value);
        value = 0;
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance); 

    }
}

contract ENS {
    // ansuchan.eth => 0x219...
    mapping(string => address) public names;

    function register(string memory _name, address _address) public {
        // 정다운을 입력했을때, 주소값이 없으면 , 만약에 없는경우 0x 0000 (address(0)라고 저장됨 주소값을 저장해라
        if (names[_name] == address(0)) {
            names[_name] = _address;
        }
    }
}