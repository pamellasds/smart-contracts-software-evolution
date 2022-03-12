pragma solidity ^0.5.16;


import ;
import ;
import ;


import ;
import ;


import ;
import ;
import ;


contract fixedsupplyschedule is owned, mixinresolver, isupplyschedule {
    using safemath for uint;
    using safedecimalmath for uint;
    using math for uint;

    

    
    uint public constant max_minter_reward = 200 ether; 

    
    uint public constant default_mint_period_duration = 1 weeks;
    
    uint public constant default_mint_buffer = 1 days;

    

    
    uint public inflationstartdate;
    
    uint public lastmintevent;
    
    uint public mintperiodcounter;
    
    uint public mintperiodduration = default_mint_period_duration;
    
    uint public mintbuffer = default_mint_buffer;
    
    uint public fixedperiodicsupply;
    
    uint public supplyend;
    
    uint public minterreward;

    

    bytes32 private constant contract_synthetix = ;

    bytes32[24] private addressestocache = [contract_synthetix];

    constructor(
        address _owner,
        address _resolver,
        uint _inflationstartdate,
        uint _lastmintevent,
        uint _mintperiodcounter,
        uint _mintperiodduration,
        uint _mintbuffer,
        uint _fixedperiodicsupply,
        uint _supplyend,
        uint _minterreward
    ) public owned(_owner) mixinresolver(_resolver, addressestocache) {
        
        if (_inflationstartdate != 0) {
            inflationstartdate = _inflationstartdate;
        } else {
            inflationstartdate = block.timestamp;
        }
        
        
        if (_lastmintevent != 0) {
            require(_lastmintevent > inflationstartdate, );
            require(_mintperiodcounter > 0, );
        }
        require(_mintbuffer <= _mintperiodduration, );
        require(_minterreward <= max_minter_reward, );

        lastmintevent = _lastmintevent;
        mintperiodcounter = _mintperiodcounter;
        fixedperiodicsupply = _fixedperiodicsupply;
        
        if (_mintbuffer != 0) {
            mintbuffer = _mintbuffer;
        }
        
        if (_mintperiodduration != 0) {
            mintperiodduration = _mintperiodduration;
        }
        supplyend = _supplyend;
        minterreward = _minterreward;
    }

    

    function synthetix() internal view returns (isynthetix) {
        return isynthetix(requireandgetaddress(contract_synthetix, ));
    }

    
    function mintablesupply() external view returns (uint) {
        uint totalamount;

        if (!ismintable() || fixedperiodicsupply == 0) {
            return 0;
        }

        uint remainingperiodstomint = periodssincelastissuance();

        uint currentperiod = mintperiodcounter;

        
        
        while (remainingperiodstomint > 0) {
            currentperiod = currentperiod.add(1);

            if (currentperiod < supplyend) {
                
                totalamount = totalamount.add(fixedperiodicsupply);
            } else {
                
                break;
            }

            remainingperiodstomint;
        }

        return totalamount;
    }

    
    function periodssincelastissuance() public view returns (uint) {
        
        
        uint timediff = lastmintevent > 0 ? block.timestamp.sub(lastmintevent) : block.timestamp.sub(inflationstartdate);
        return timediff.div(mintperiodduration);
    }

    
    function ismintable() public view returns (bool) {
        if (block.timestamp  lastmintevent > mintperiodduration) {
            return true;
        }
        return false;
    }

    

    
    function recordmintevent(uint supplyminted) external onlysynthetix returns (bool) {
        uint numberofperiodsissued = periodssincelastissuance();

        
        mintperiodcounter = mintperiodcounter.add(numberofperiodsissued);

        
        
        lastmintevent = inflationstartdate.add(mintperiodcounter.mul(mintperiodduration)).add(mintbuffer);

        emit supplyminted(supplyminted, numberofperiodsissued, lastmintevent, block.timestamp);
        return true;
    }

    

    
    function setminterreward(uint amount) external onlyowner {
        require(amount <= max_minter_reward, );
        minterreward = amount;
        emit minterrewardupdated(minterreward);
    }

    

    
    modifier onlysynthetix() {
        require(msg.sender == address(synthetix()), );
        _;
    }

    
    
    event supplyminted(uint supplyminted, uint numberofperiodsissued, uint lastmintevent, uint timestamp);

    
    event minterrewardupdated(uint newrewardamount);
}
