pragma solidity ^0.4.15;

import ;

contract land is basicnft {

  string public name = ;
  string public symbol = ;

  address claimcontract;
  mapping (uint => uint) latestping;

  event tokenping(uint tokenid);

  land(address _claimcontract) {
    claimcontract = _claimcontract;
  }

  assignnewparcel(address beneficiary, uint tokenid, bytes metadata) {
    require(msg.sender == claimcontract);
    require(!tokenowner[tokenid]);
    latestping[tokenid] = now;
    _addtokento(beneficiary, tokenid);
    tokencreated(tokenid, beneficiary, metadata);
  }

  ping(uint tokenid) {
    require(msg.sender == tokenowner[tokenid]);
    latestping[tokenid] = now;
    tokenping(tokenid);
  }

  claimforgottenparcel(address beneficiary, uint tokenid) {
    require(tokenowner[tokenid] != 0);
    require(latestping[tokenid] < now);
    require(now  latestping[tokenid] > 1 year);
    _transfer(tokenowner[tokenid], beneficiary, tokenid);
    tokentransferred(tokenid, from, to);
  }
}
