


pragma solidity 0.4.25;


import ;
import ;
import ;
import ;

contract rewardsdistribution is owned {
    using safemath for uint;
    using safedecimalmath for uint;

    
    address public authority;

    
    address public synthetixproxy;
    
    
    address public rewardescrow;

    
    address public feepoolproxy;

    
    struct distributiondata {
        address destination;
        uint amount;
    }

    
    distributiondata[] public distributions;

    
    constructor(address _owner, address _authority, address _synthetixproxy, address _rewardescrow, address _feepoolproxy)
        owned(_owner)
        public
    {
        authority = _authority;
        synthetixproxy = _synthetixproxy;
        rewardescrow = _rewardescrow;
        feepoolproxy = _feepoolproxy;
    }

    

    function setsynthetixproxy(address _synthetixproxy)
        external
        onlyowner
    {
        synthetixproxy = _synthetixproxy;
    }

    function setrewardescrow(address _rewardescrow)
        external
        onlyowner
    {
        rewardescrow = _rewardescrow;
    }

    function setfeepoolproxy(address _feepoolproxy)
        external
        onlyowner
    {
        feepoolproxy = _feepoolproxy;
    }

    
    function setauthority(address _authority)
        external
        onlyowner
    {
        authority = _authority;
    }

    

    
    function addrewarddistribution(address destination, uint amount)
        external
        onlyowner
        returns (bool)
    {
        require(destination != address(0), );
        require(amount != 0, );

        distributiondata memory rewardsdistribution = distributiondata(destination, amount);
        distributions.push(rewardsdistribution);

        emit rewarddistributionadded(distributions.length  1, destination, amount);
        return true;
    }

    
    function removerewarddistribution(uint index)
        external
        onlyowner
    {
        require(index <= distributions.length  1, );

        
        for (uint i = index; i < distributions.length  1; i++) {
            distributions[i] = distributions[i+1];
        }
        distributions.length;
    }

     
    function editrewarddistribution(uint index, address destination, uint amount)
        external
        onlyowner
        returns (bool)
    {
        require(index <= distributions.length  1, );

        distributions[index].destination = destination;
        distributions[index].amount = amount;

        return true;
    }

    
    function distributerewards(uint amount)
        external
        returns (bool)
    {
        require(msg.sender == authority, );
        require(rewardescrow != address(0), );
        require(synthetixproxy != address(0), );
        require(feepoolproxy != address(0), );
        require(amount > 0, );
        require(ierc20(synthetixproxy).balanceof(this) >= amount, );
                
        uint remainder = amount;

        
        for (uint i = 0; i < distributions.length; i++) {
            if (distributions[i].destination != address(0) || distributions[i].amount != 0) {
                remainder = remainder.sub(distributions[i].amount);
                ierc20(synthetixproxy).transfer(distributions[i].destination, distributions[i].amount);
            }
        }

        
        ierc20(synthetixproxy).transfer(rewardescrow, remainder);

        
        ifeepool(feepoolproxy).setrewardstodistribute(remainder);

        emit rewardsdistributed(amount);
        return true;
    }

    

    
    function distributionslength()
        external
        view
        returns (uint)
    {
        return distributions.length;
    }

    

    event rewarddistributionadded(uint index, address destination, uint amount);
    event rewardsdistributed(uint amount);
}
