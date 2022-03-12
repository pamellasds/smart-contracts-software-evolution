pragma solidity ^0.4.15;

import ;
import ;

contract land is ownable, basicnft {

  string public name = ;
  string public symbol = ;

  mapping (uint => uint) public latestping;

  event tokenping(uint tokenid);

  function assignnewparcel(address beneficiary, uint tokenid, string _metadata) onlyowner public {
    require(tokenowner[tokenid] == 0);
    latestping[tokenid] = now;
    _addtokento(beneficiary, tokenid);
    totaltokens++;
    tokenmetadata[tokenid] = _metadata;
    tokencreated(tokenid, beneficiary, _metadata);
  }

  function ping(uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);
    latestping[tokenid] = now;
    tokenping(tokenid);
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

  function approvelandtransfer(address to, uint x, uint y) public {
    return approve(to, buildtokenid(x, y));
  }

  function transferlandfrom(address from, address to, uint x, uint y) public {
    return transferfrom(from, to, buildtokenid(x, y));
  }

  function landmetadata(uint x, uint y) constant public returns (string) {
    return tokenmetadata[buildtokenid(x, y)];
  }

  function updatelandmetadata(uint x, uint y, string _metadata) public {
    return updatetokenmetadata(buildtokenid(x, y), _metadata);
  }

  function claimforgottenparcel(address beneficiary, uint tokenid) onlyowner public {
    require(tokenowner[tokenid] != 0);
    require(latestping[tokenid] < now);
    require(now  latestping[tokenid] > 1 years);
    address oldowner = tokenowner[tokenid];
    latestping[tokenid] = now;
    _transfer(oldowner, beneficiary, tokenid);
    tokentransferred(tokenid, oldowner, beneficiary);
  }
}
