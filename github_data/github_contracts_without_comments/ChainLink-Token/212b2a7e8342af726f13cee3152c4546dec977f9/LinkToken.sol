pragma solidity ^0.6.0;

import ;
import ;

contract linktoken is linkerc20, erc677token {
  uint private constant total_supply = 10**27;
  string private constant name = ;
  string private constant symbol = ;

  constructor() erc20(name, symbol)
    public
  {
    _oncreate();
  }

  
  function _oncreate()
    internal
    virtual
  {
    _mint(msg.sender, total_supply);
  }

  
  function _transfer(address sender, address recipient, uint256 amount)
    internal
    override
    virtual
    validaddress(recipient)
  {
    super._transfer(sender, recipient, amount);
  }

  
  function _approve(address owner, address spender, uint256 amount)
    internal
    override
    virtual
    validaddress(spender)
  {
    super._approve(owner, spender, amount);
  }


  

  modifier validaddress(address _recipient) {
    require(_recipient != address(this), );
    _;
  }
}
