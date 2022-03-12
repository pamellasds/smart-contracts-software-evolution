pragma solidity ^ 0.4 .15;

import ;

import ;
import ;

import ;

contract rentingcontract is ownable {
    using safemath
    for uint256;

    
    landtoken public landcontract;

    uint256 public upfrontcost;
    uint256 public ownerterminationcost;
    uint256 public weeklycost;
    uint256 public costpersecond;

    address public tenant;
    uint256 public rentstartedat;
    uint256 public tenantbalance;

    function rentingcontract(landtoken _landcontract, uint256 _upfrontcost, uint256 _ownerterminationcost, uint256 _weeklycost) {
        require(address(_landcontract) != 0);
        landcontract = _landcontract;

        upfrontcost = _upfrontcost;
        weeklycost = _weeklycost;
        ownerterminationcost = _ownerterminationcost;
        costpersecond = weeklycost / 1 weeks;
    }

    function totaldue(uint256 time) returns(uint256) {
        return time.sub(rentstartedat).mul(costpersecond).add(upfrontcost);
    }

    function totalduesofar() returns(uint256) {
        return totaldue(now);
    }

    function isrented() public returns(bool) {
        return tenant != 0;
    }

    function isdue() public returns(bool) {
        return isrented() && totalduesofar() >= tenantbalance;
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
        require(msg.sender == tenant || msg.sender == owner);
        _;
    }

    
    function rent() payable onlyifsetup onlyifnotrented {
        uint256 paid = msg.value;
        
        require(totaldue(now + 1 weeks) >= upfrontcost.add(weeklycost));

        tenant = msg.sender;
        rentstartedat = now;
        tenantbalance = paid;
    }

    
    function payrent() payable onlyifrented {
        uint256 paid = msg.value;
        tenantbalance = tenantbalance.add(paid);
    }

    function evict() public returns(bool) {
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
        upfrontcost = 0;
        weeklycost = 0;
        ownerterminationcost = 0;
        costpersecond = 0;
    }

    function changepricing(
        uint256 _upfrontcost,
        uint256 _weeklycost,
        uint256 _ownerterminationcost,
        uint256 _costpersecond
    )
    public
    onlyowner
    onlyifnotrented 
    {
        upfrontcost = _upfrontcost;
        weeklycost = _weeklycost;
        ownerterminationcost = _ownerterminationcost;
        costpersecond = _costpersecond;
    }


    function cancelcontract() payable public onlyowner onlyifrented {
        require(msg.value >= ownerterminationcost);
        _release();
        tenant.transfer(msg.value);
    }

    function transfer(address target, uint256 tokenid) public onlyowner onlyifnotrented {
        
        landcontract.transfer(target, tokenid);
    }

    function retrievefunds() public onlyowner {
        owner.transfer(this.balance);
    }

    function updatelandforowner(string _metadata, uint256 tokenid) public onlyowner onlyifnotrented {
        landcontract.updatetokenmetadata(tokenid, _metadata);
    }

    function updateland(string _metadata, uint256 tokenid) public onlytenant onlyifrented {
        landcontract.updatetokenmetadata(tokenid, _metadata);
    }

    function pingland(uint256 tokenid) public onlytenantorowner {
        landcontract.ping(tokenid);
    }
    
    function selfdestruct(uint256[] lands) public onlyowner onlyifnotrented {
        for(int i = 0; i < lands.length(); i++) {
            transfer(owner, lands[i]); 
        }
        suicide(owner);
    }
}
