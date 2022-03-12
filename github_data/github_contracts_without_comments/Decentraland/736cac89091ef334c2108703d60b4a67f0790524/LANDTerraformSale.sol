pragma solidity ^0.4.15;

import ;
import ;
import ;


contract landterraformsale is landsale, ownable {

  
  returnvestingregistry public returnvesting;

  
  address public terraformreserve;

  
  function landterraformsale(address _token, address _terraformreserve, address _returnvesting) public {
    token = burnabletoken(_token);
    returnvesting = returnvestingregistry(_returnvesting);
    terraformreserve = _terraformreserve;

    land = _deployland();
  }

  
  function buy(address _buyer, uint256 _x, uint256 _y, uint256 _cost) onlyowner public {
    _buyland(_x, _y, , _buyer, terraformreserve, _cost);
  }

  
  function buymany(address _buyer, uint256[] _x, uint256[] _y, uint256 _totalcost) onlyowner public {
    require(_x.length == _y.length);

    
    if (!token.transferfrom(terraformreserve, this, _totalcost)) {
      revert();
    }
    token.burn(_totalcost);

    for (uint256 i = 0; i < _x.length; i++) {
      land.assignnewparcel(_buyer, buildtokenid(_x[i], _y[i]), );
    }
  }

  
  function transferbackmana(address _address, uint256 _amount) onlyowner public {
    require(_address != address(0));
    require(_amount > 0);

    address returnaddress = _address;

    
    if (returnvesting != address(0)) {
      address mappedaddress = returnvesting.returnaddress(_address);
      if (mappedaddress != address(0)) {
        returnaddress = mappedaddress;
      }
    }

    
    require(token.transferfrom(terraformreserve, returnaddress, _amount));
  }

  
  function transferbackmanamany(address[] _addresses, uint256[] _amounts) onlyowner public {
    require(_addresses.length == _amounts.length);

    for (uint256 i = 0; i < _addresses.length; i++) {
      transferbackmana(_addresses[i], _amounts[i]);
    }
  }

  
  function transferlandownership(address _newowner) onlyowner public {
    land.transferownership(_newowner);
  }

  
  function _deployland() internal returns (landtoken) {
    return new landtoken();
  }

  
  function _isvalidland(uint256 _x, uint256 _y) internal returns (bool) {
    return true;
  }
}
