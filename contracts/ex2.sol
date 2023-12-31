// SPDX-License-Identifier: onther
pragma solidity ^0.8.19;
/*
1. EIP-20 transfer() + balances
2. EIP-20 transferFrom(), approve() + allowances
3. (1) Wrapped Ether, (2) Transfer(*)

EIP-20
- 9 Methods + 2 Events

[ERC20 Methods]
1. name
2. symbol
3. decimals
4. totalSupply
5. transfer(to, amount) -> emit Transfer
6. transferFrom(from, to, amount) -> emit Transfer
7. approve(to, amount): 주체 : 본인(owner/from) 
8. allowance -> emit Approval
9. balanceOf

[ERC20 Events]

1. Transfer
2. Approval

*/


/// 예제 : mapping(address owner => uint amount) public balances;
//특수한 경우(매년 토큰의 갯수가 리셋)
// (1) Contract를 매년 배포(2023토큰컨트랙, 2024토큰컨트랙)
// (2) 단일 Contract로 매년/모든 해외 토큰을 관리
/// 예제 업그레이드 -> mapping(uint year => mapping(address owner => uint amount)) public balancesOfYears;
//balancesOfYears[2023][0x..] = 100;
//balancesOfYears[2022][0x..] = 0;

contract MyFirstToken {
    string public name = "dawoon Web Ether";
    string public symbol = "jdwWETH";
    uint public decimals = 18;
    uint public totalSupply = 0;

    /// 해당 변수가 아무 역할은 없지만 명시적인 역할을 함
    mapping(address owner => uint amount) public balances;
    // 누가, 누구에게, 얼마만큼 권한을 주었는가? 의 데이터 타입 필요
    mapping(address owner => mapping(address spender => uint)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);


    // transfer, balanceOf
    function balanceOf(address owner) public view returns (uint amount) {
        return balances[owner];
    }

    // 실행 주체 : owner(from)
    function transfer(address to, uint amount) public returns (bool success) {
        // 1. 예외 에러 고민해야함
        address owner = msg.sender;
        // transfer 대표 예외 : 내가 가진 잔고보다, 많은 금액을 추금하려고 하면 에러!
        require(balances[owner] >= amount);
        // 2. 잔고/데이터를 업데이트
        // from (-)
        //balances[owner] = balances[owner] - amount;
        balances[owner] -= amount;
        // to (+)
        balances[to] += amount;
        // Event 
        emit Transfer(owner, to, amount);
        return true;

        // 아래 과정들을 계속 고민해보면서 컨트랙트를 짠다.
        // 1. Error
        // 2. Data Update
        // 3. Event
        // 4. Return true 

    }

    // transfer 응용
    // 수수료를 뺀 함수
    function transfer2(address to, uint amount) public returns (bool success) {
        address owner = msg.sender;
        require(balances[owner] >= amount);

        uint fee = amount / 10;
        uint amountWithoutFee = amount - fee;

        balances[owner] -= amount;
        balances[to] += amountWithoutFee;
        address developer = 0x46897603e2A82755E9c416eF828Bd1515536b3D5;
        balances[developer] += fee;

        emit Transfer(owner, to, amount);
        emit Transfer(owner, 0x46897603e2A82755E9c416eF828Bd1515536b3D5, fee);
        return true;
    }



    // 실행주체를 먼저 고민
    // spender(Uniswap pair, Exchange)
    function transferFrom(address owner, address to, uint amount) public returns (bool success) {
        address spender = msg.sender;
        
        // 아래 과정들을 계속 고민해보면서 컨트랙트를 짠다.
        // 1. Error
        // - 잔액이 충분한가? owner's balance => amount
        require(balances[owner] >= amount);
        // - 권한이 있는가? spender's allowance >= amount // spender의 권한이 보내려고 하는 amount보다 더 큰가
        require(allowances[owner][spender] >= amount);
        // 2. Data Update
        // - balances
        balances[owner] -= amount;
        balances[to] += amount;
        // - allowances
        allowances[owner][spender] -= amount;
        // 3. Event
        emit Transfer(owner, to, amount);
        // 4. Return true 
        return true;
    }

    // 실행 주체 : owner
    function approve(address spender, uint amount) public returns (bool success) {
        address owner = msg.sender;
        allowances[owner][spender] = amount;
        // unapprove는  approve를 0만큼 덮어 씌우는것 = approve(0)
        emit Approval(owner, spender, amount);
        return true;

    }

    function allowance(address owner, address spender) public view returns (uint amount) {
        return allowances[owner][spender];
    }


    // 얼마를 받아서(payable로 받아서 msg.value만큼 받는다.), 누구에게 WETH를 민팅해줄까?
    function deposit() public payable returns (bool success) {
        address owner = msg.sender;
        uint amount = msg.value;

        balances[owner] += amount;
        totalSupply += amount;
        emit Transfer(address(0), owner, amount);

        return true;
    }

    // tokenToEth()
    // 얼마만큼 바꿀것인지 적혀있어야 함
    function withdraw(uint amount) public returns (bool suceess) {
        address owner = msg.sender;

        balances[owner] -= amount;
        totalSupply -= amount;

        // 사람에 따라 withdraw 를 다르게 생각할 수 있음
        // (1) withdrwa는 토큰을 소각하는 행위
        // (2) withdrwa는 자사주를 매입하는 행위
        // withdraw 하면, WETH 자체를 CA가 보유하는 행위로 생각할 수도 있음
        /*
            balances[owner] -= amount;
            balances[address(this)] += amount;
        */
        // Ether(CA -> owner)
        payable(owner).transfer(amount);
        emit Transfer(owner, address(0), amount);
        return true;
    }
    
}