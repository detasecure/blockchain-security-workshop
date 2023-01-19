pragma solidity 0.6.0;
contract Token {
  mapping(address => uint) balances;
  mapping (address=>uint256) getBalance;
  uint public totalSupply;
  address public minter;


  constructor() public {
        minter=msg.sender;
    }
  function token(uint _initialSupply) public {
    balances[minter] = totalSupply = _initialSupply;
  }

  function deposit_and_mint(address _to, uint256 amount) external {
        require(msg.sender==minter,"Not an minter");
        getBalance[_to] += amount;
    }
  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
