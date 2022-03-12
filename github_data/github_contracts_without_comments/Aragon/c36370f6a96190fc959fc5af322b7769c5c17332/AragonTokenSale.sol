pragma solidity ^0.4.6;

import ;
import ;

contract aragontokensale is tokencontroller {
    uint public startfundingtime;       
    uint public endfundingtime;         
    uint public totalcollected;         
    bool public salestopped;            
    uint public initialprice;
    uint public finalprice;
    uint8 public pricestages;

    minimetoken public token;           
    address public aragondevmultisig;   
    address public communitymultisig;   
    address public aragonnetwork;       

    uint public dust = 1 finney;        









    function aragontokensale (
        uint _startfundingtime,
        uint _endfundingtime,
        address _aragondevmultisig,
        address _communitymultisig,
        uint256 _initialprice,
        uint256 _finalprice,
        uint8 _pricestages
    ) {
        if ((_endfundingtime < now) ||
            (_endfundingtime <= _startfundingtime) ||
            (_aragondevmultisig == 0x0 || communitymultisig == 0x0) ||
            (_initialprice > _finalprice) ||
            (_pricestages < 1))
        {
          throw;
        }
        startfundingtime = _startfundingtime;
        endfundingtime = _endfundingtime;
        aragondevmultisig = _aragondevmultisig;
        communitymultisig = _communitymultisig;
        initialprice = _initialprice;
        finalprice = _finalprice;
        pricestages = _pricestages;

        deployant();
    }

    function deployant() {
      minimetokenfactory factory = new minimetokenfactory();
      if (address(factory) != addressforcontract(1)) throw;

      
      token = new minimetoken(address(factory), 0x0, 0, , 18, , true);
      if (address(token) != addressforcontract(2)) throw;

      aragonnetwork = addressforcontract(3); 
    }

    function getprice(uint date) constant returns (uint256) {
      if (date < startfundingtime || date > endfundingtime) return 2**250;

      return priceforstage(stagefordate(date));
    }

    function stagefordate(uint date) constant returns (uint8) {
      return uint8(uint256(pricestages) * (date  startfundingtime) / (endfundingtime  startfundingtime));
    }

    function priceforstage(uint8 stage) constant returns (uint256) {
      uint256 stagedelta = (finalprice  initialprice) / uint256(pricestages  1);
      return initialprice + uint256(stage) * stagedelta;
    }

    function allocatepresaletokens(address receiver, uint amount) only(aragondevmultisig) {
      if (now >= startfundingtime) throw;
      if (!token.generatetokens(receiver, amount)) throw;
    }

    function deploynetwork(bytes networkcode) only(communitymultisig) {
      if (now <= endfundingtime || !salestopped) throw;

      address deployedaddress;
      assembly {
        deployedaddress := create(0,add(networkcode,0x20), mload(networkcode))
        jumpi(invalidjumplabel,iszero(extcodesize(deployedaddress)))
      }

      if (deployedaddress != aragonnetwork) throw;
    }

    function addressforcontract(uint8 n) constant returns (address) {
      return address(sha3(0xd6, 0x94, this, n));
    }






    function () payable {
      dopayment(msg.sender);
    }









    function proxypayment(address _owner) payable returns(bool) {
      dopayment(_owner);
      return true;
    }







    function ontransfer(address _from, address _to, uint _amount) returns(bool) {
      return true;
    }







    function onapprove(address _owner, address _spender, uint _amount) returns(bool) {
      return true;
    }






    function dopayment(address _owner) internal {
      if ((now < startfundingtime) || (now > endfundingtime)) throw;
      if (salestopped) throw;
      if (token.controller() != address(this)) throw;
      if (msg.value < dust) throw;

      totalcollected += msg.value;
      uint256 boughttokens = msg.value / getprice(now);

      if (!aragondevmultisig.send(msg.value)) throw;
      if (!token.generatetokens(_owner, boughttokens)) throw;

      return;
    }






    function finalizesale() only(aragondevmultisig) {
      if (now < endfundingtime) throw;

      uint256 aragontokens = token.totalsupply() / 4; 
      if (!token.generatetokens(aragondevmultisig, aragontokens)) throw;
      salestopped = true;
      token.changecontroller(aragonnetwork);
    }

    function setaragondevmultisig(address _newmultisig) only(aragondevmultisig) {
      aragondevmultisig = _newmultisig;
    }

    function setcommunitymultisig(address _newmultisig) only(communitymultisig) {
      communitymultisig = _newmultisig;
    }

    modifier only(address x) {
      if (msg.sender != x) throw;
      _;
    }
}
