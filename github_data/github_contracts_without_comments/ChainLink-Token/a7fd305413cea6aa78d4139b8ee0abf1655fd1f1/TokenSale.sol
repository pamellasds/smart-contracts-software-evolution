pragma solidity ^0.4.11;


import ;
import ;
import ;


contract tokensale is ownable {

  using safemath for uint;

  uint public limit;
  uint public starttime;
  uint public distributed;
  uint constant public phaseoneend = 1 days;
  uint constant public phasetwoend = 7 days;
  uint constant public phasethreeend = 14 days;
  uint constant public endtime = 28 days;
  address public recipient;
  linktoken public token;

  function tokensale(uint _limit, uint _prepurchased, uint _start, address _owner)
  public
  {
    limit = _limit;
    distributed = _prepurchased;
    starttime = _start;
    token = new linktoken();
    owner = _owner;

    require(limit <= token.totalsupply());
  }

  function ()
  public payable ensurestarted ensurenotended underlimit
  {
    if (owner.send(msg.value)) {
      uint purchaseamount = purchased();
      distributed = distributed.add(purchaseamount);
      token.transfer(msg.sender, purchaseamount);
    }
  }

  function closeout()
  public onlyowner ensurestarted ensurecompleted
  {
    token.transfer(owner, token.balanceof(this));
  }

  function completed()
  public constant returns (bool)
  {
    return ended() || funded();
  }


  

  function purchased()
  private returns (uint)
  {
    uint start = starttime;
    if (block.timestamp <= start + phaseoneend) {
      return msg.value.div(10**6).mul(2);
    } else if (block.timestamp <= start + phasetwoend) {
      return msg.value.mul(18).div(10**7);
    } else if (block.timestamp <= start + phasethreeend) {
      return msg.value.mul(15).div(10**7);
    } else {
      return msg.value.mul(12).div(10**7);
    }
  }

  function started()
  private returns (bool)
  {
    return block.timestamp >= starttime;
  }

  function ended()
  private returns (bool)
  {
    return block.timestamp > starttime + endtime;
  }

  function funded()
  private returns (bool)
  {
    return distributed == limit;
  }


  

  modifier ensurestarted()
  {
    require(started());
    _;
  }

  modifier ensurenotended()
  {
    require(!ended());
    _;
  }

  modifier ensurecompleted()
  {
    require(completed());
    _;
  }

  modifier underlimit()
  {
    require(purchased() + distributed <= limit);
    _;
  }

}
