pragma solidity ^0.4.15;

import ;
import ;

contract landtoken is ownable, basicnft {

  string public name = ;
  string public symbol = ;

  mapping (uint => uint) public latestping;

  event ping(uint tokenid);

  function assignnewparcel(address beneficiary, uint tokenid, string _metadata) onlyowner public {
    require(tokenowner[tokenid] == 0);
    _assignnewparcel(beneficiary, tokenid, _metadata);
  }

  function _assignnewparcel(address beneficiary, uint tokenid, string _metadata) internal {
    latestping[tokenid] = now;
    _addtokento(beneficiary, tokenid);
    totaltokens++;
    _tokenmetadata[tokenid] = _metadata;

    created(tokenid, beneficiary, _metadata);
  }

  function ping(uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);

    latestping[tokenid] = now;

    ping(tokenid);
  }

  function buildtokenid(uint x, uint y) public constant returns (uint256) {
    return uint256(sha3(x, , y));
  }

  function exists(uint x, uint y) public constant returns (bool) {
    return ownerofland(x, y) != 0;
  }

  function ownerofland(uint x, uint y) public constant returns (address) {
    return tokenowner[buildtokenid(x, y)];
  }

  function transferland(address to, uint x, uint y) public {
    return transfer(to, buildtokenid(x, y));
  }

  function takeland(uint x, uint y) public {
    return takeownership(buildtokenid(x, y));
  }

  function approvelandtransfer(address to, uint x, uint y) public {
    return approve(to, buildtokenid(x, y));
  }

  function landmetadata(uint x, uint y) constant public returns (string) {
    return _tokenmetadata[buildtokenid(x, y)];
  }

  function updatelandmetadata(uint x, uint y, string _metadata) public {
    return updatetokenmetadata(buildtokenid(x, y), _metadata);
  }

  function updatemanylandmetadata(uint[] x, uint[] y, string _metadata) public {
    for (uint i = 0; i < x.length; i++) {
      updatetokenmetadata(buildtokenid(x[i], y[i]), _metadata);
    }
  }

  function claimforgottenparcel(address beneficiary, uint tokenid) onlyowner public {
    require(tokenowner[tokenid] != 0);
    require(latestping[tokenid] < now);
    require(now  latestping[tokenid] > 1 years);

    address oldowner = tokenowner[tokenid];
    latestping[tokenid] = now;
    _transfer(oldowner, beneficiary, tokenid);

    transferred(tokenid, oldowner, beneficiary);
  }
}
