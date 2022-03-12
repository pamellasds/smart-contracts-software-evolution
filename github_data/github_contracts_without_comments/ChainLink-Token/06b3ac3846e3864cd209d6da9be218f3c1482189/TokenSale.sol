pragma solidity ^0.4.11;


import ;
import ;
import ;


contract tokensale is ownable {

  using safemath for uint;

  uint public limit;
  uint public starttime;
  uint public distributed;
  uint constant public phase1end = 1 days;
  uint constant public phase2end = 7 days;
  uint constant public phase3end = 14 days;
  uint constant public phase4end = 21 days;
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
    if (block.timestamp <= start + phase1end) {
      return msg.value.mul(200).div(10**8);
    } else if (block.timestamp <= start + phase2end) {
      return msg.value.mul(175).div(10**8);
    } else if (block.timestamp <= start + phase3end) {
      return msg.value.mul(165).div(10**8);
    } else if (block.timestamp <= start + phase4end) {
      return msg.value.mul(155).div(10**8);
    } else {
      return msg.value.mul(145).div(10**8);
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
