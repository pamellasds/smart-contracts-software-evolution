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
  address public distributionupdater;
  linktoken public token;

  function tokensale(
    uint _limit,
    uint _prepurchased,
    uint _start,
    address _owner,
    address _distributionupdater
  )
  public
  {
    limit = _limit;
    distributed = _prepurchased;
    starttime = _start;
    token = new linktoken();
    owner = _owner;
    distributionupdater = _distributionupdater;

    require(limit <= token.totalsupply());
  }

  function ()
  public payable
  {
    purchase(msg.sender);
  }

  function purchase(address _recipient)
  public payable ensurestarted ensurenotcompleted
  {
    uint purchaseamount = calculatepurchased();

    require(underlimit(purchaseamount) && owner.send(msg.value));

    distributed = distributed.add(purchaseamount);
    token.transfer(_recipient, purchaseamount);
  }

  function completed()
  public constant returns (bool)
  {
    return ended() || funded() || finalized;
  }

  function closeout()
  public onlyowner ensurestarted ensurecompleted
  {
    token.transfer(owner, token.balanceof(this));
  }

  function finalize()
  public onlyowner ensurestarted
  {
    finalized = true;
  }

  function updatedistributed(uint amountchanged)
  public onlydistributionupdater
  {
    distributed = distributed.add(amountchanged);
  }


  

  bool finalized;

  function calculatepurchased()
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

  function underlimit(uint _purchasedamount)
  private returns (bool)
  {
    return (_purchasedamount + distributed <= limit);
  }


  

  modifier ensurestarted()
  {
    require(started());
    _;
  }

  modifier ensurenotcompleted()
  {
    require(!completed());
    _;
  }

  modifier ensurecompleted()
  {
    require(completed());
    _;
  }

  modifier onlydistributionupdater()
  {
    require(msg.sender == distributionupdater);
    _;
  }

}
