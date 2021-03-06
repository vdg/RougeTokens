/*

  Contract to implement ERC20 tokens for the advisor bonus + bounty campaigns of the Rouge Project
  (RGXA and RGXB tokens).
  They are based on ConsenSys EIP20 token standard implementation (https://github.com/ConsenSys/Tokens).

  Differences with standard ERC20 tokens :

   - owner can distribute token until fundingEnd (non resersible);
   - discountMultiplier as in RGXToken is saved which can be used later on 
     by other contracts (eg to use the tokens as discount coupons/vouchers).

*/

import "./EIP20.sol";

pragma solidity ^0.4.23;

contract RGXBonus is EIP20 {
    
    address owner; 
    uint public fundingEnd;
    uint8 public discountMultiplier;
    uint8 public discountDecimal;
    string public version = 'v2.1';
    
    modifier fundingOpen() {
        require(now < fundingEnd);
        _;
    }
    
    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }
    
    function() public payable { }
    
    constructor(
                string _name,
                string _symbol,
                uint _fundingEnd,
                uint8 _discountMultiplier,
                uint8 _discountDecimal
                ) EIP20 (0, _name, 0, _symbol) public {
        owner = msg.sender;
        fundingEnd = _fundingEnd;
        discountMultiplier = _discountMultiplier;
        discountDecimal = _discountDecimal;
    }
    
    function isFundingOpen() constant public returns (bool yes) {
        return (now < fundingEnd);
    }
    
    function distribute(address _to, uint256 _value) onlyBy(owner) fundingOpen() public {
        totalSupply += _value;
        balances[_to] += _value;
        emit Transfer(owner, _to, _value);
    }

    function endFunding(uint _fundingEnd) onlyBy(owner) fundingOpen() public {
        fundingEnd = _fundingEnd;
    }

    function withdraw() onlyBy(owner) public {
        msg.sender.transfer(address(this).balance);
    }
    
    function kill() onlyBy(owner) public {
        selfdestruct(owner);
    }

}
