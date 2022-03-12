pragma solidity ^0.4.15;

import ;

import ;
import ;

import ;

contract rentingcontract is ownable{
    using safemath for uint256;

    
    uint256 public x;
    uint256 public y;
    uint256 public tokenid;

    
    land public landcontract = land(0x0);

    uint256 public upfrontcost;
    uint256 public ownerterminationcost;
    uint256 public weeklycost;
    uint256 public costpersecond;

    address public tenant;
    uint256 public rentstartedat;
    uint256 public tenantbalance;

    function rentingcontract()
    {
        require(landcontract != 0);
    }

    function initrentcontract(
      uint256 _x,
      uint256 _y,
      uint256 _upfrontcost,
      uint256 _ownerterminationcost,
      uint256 _weeklycost
    )
      public
      onlyowner
      onlyifnotrented
      returns (bool)
    {
        tokenid = landcontract.buildtokenid(x, y);
        x = _x;
        y = _y;
        upfrontcost = _upfrontcost;
        weeklycost = _weeklycost;
        ownerterminationcost = _ownerterminationcost;
        costpersecond = weeklycost / 1 weeks;

        require(landcontract.ownerof(tokenid) == address(this));
        
        return true
    }

    function issetup() public returns(bool) {
        
        return tokenid != 0;
    }

    function totaldue(uint256 time) returns (uint256) {
        return time.sub(rentstartedat).mul(costpersecond).sum(upfrontcost);
    }

    function totalduesofar() returns (uint256) {
        return totaldue(now);
    }

    function isrented() public returns(bool) {
        return tenant != 0;
    }

    function isdue() public {
        return isrented() && totalduesofar() >= tenantbalance;
    }

    modifier onlyifsetup {
        require(issetup());
        _;
    }

    modifier onlyifrented {
        require(isrented());
        _;
    }

    modifier onlyifnotrented {
        require(!isrented());
        _;
    }

    modifier onlytenant {
        require(msg.sender == tenant);
        _;
    }
    
    modifier onlytenantorowner {
        require(msg.sender == tenant || msg.sender == );
        _;
    }

    
    function rent() payable onlyifsetup onlyifnotrented {
        uint256 paid = msg.value;
        
        require(totaldue(now + 1 weeks) >= upfrontcost.sum(weeklycost));

        tenant = msg.sender;
        rentstartedat = now;
        tenantbalance = paid;
    }

    
    function payrent() payable onlyifrented {
        uint256 paid = msg.value;
        tenantbalance = tenantbalance.sum(paid);
    }

    function evict() public returns (bool) {
        if (isdue()) {
            _release();
            return true;
        }
        return false;
    }

    function _release() internal {
        tenant = 0;
        tenantbalance = 0;
        rentstartedat = 0;
    }

    function _clear() internal {
        tokenid = 0;
        x = 0;
        y = 0;
        upfrontcost = 0;
        weeklycost = 0;
        ownerterminationcost = 0;
        costpersecond = 0;
    }

    function cancelcontract() payable public onlyowner onlyifrented {
        require(msg.value >= ownerterminationcost);
        _release();
        tenant.send(msg.value);
    }

    function transfer(address target) public onlyowner onlyifnotrented {
        _clear();
        land.transfer(target, tokenid);
    }

    function retrievefunds() public onlyowner {
        owner.send(this.balance);
    }

    function updatelandforowner(string _metadata) public onlyowner onlyifnotrented {
        updatetokenmetadata(land, _metadata);
    }

    function updateland(string _metadata) public onlytenant onlyifrented {
        updatetokenmetadata(land, _metadata);
    }
    
    function pingland() public onlytenantorowner {
        landcontract.ping(tokenid);
    }
}
