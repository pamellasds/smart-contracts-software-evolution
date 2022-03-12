pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract exchanger is mixinresolver {
    using safemath for uint;
    using safedecimalmath for uint;

    bool public exchangeenabled = true;

    uint public gaspricelimit;

    address public gaslimitoracle;

    bytes32 private constant susd = ;

    constructor(address _owner, address _resolver) public mixinresolver(_owner, _resolver) {}

    

    function synthetix() internal view returns (isynthetix) {
        require(resolver.getaddress() != address(0), );
        return isynthetix(resolver.getaddress());
    }

    function feepool() internal view returns (ifeepool) {
        require(resolver.getaddress() != address(0), );
        return ifeepool(resolver.getaddress());
    }

    function exchangerates() internal view returns (iexchangerates) {
        require(resolver.getaddress() != address(0), );
        return iexchangerates(resolver.getaddress());
    }

    function calculateexchangeamountminusfees(
        bytes32 sourcecurrencykey,
        bytes32 destinationcurrencykey,
        uint destinationamount
    ) public view returns (uint, uint) {
        
        uint amountreceived = destinationamount;

        
        uint exchangefeerate = feerateforexchange(sourcecurrencykey, destinationcurrencykey);

        amountreceived = destinationamount.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));

        uint fee = destinationamount.sub(amountreceived);

        return (amountreceived, fee);
    }

    
    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) public view returns (uint) {
        
        uint exchangefeerate = feepool().exchangefeerate();

        uint multiplier = 1;

        
        
        if (
            (sourcecurrencykey[0] == 0x73 && sourcecurrencykey != susd && destinationcurrencykey[0] == 0x69) ||
            (sourcecurrencykey[0] == 0x69 && destinationcurrencykey != susd && destinationcurrencykey[0] == 0x73)
        ) {
            
            multiplier = 2;
        }

        return exchangefeerate.mul(multiplier);
    }

    function validategasprice(uint _givengasprice) public view {
        require(_givengasprice <= gaspricelimit, );
    }

    

    function setexchangeenabled(bool _exchangeenabled) external onlyowner {
        exchangeenabled = _exchangeenabled;
    }

    function setgaslimitoracle(address _gaslimitoracle) external onlyowner {
        gaslimitoracle = _gaslimitoracle;
    }

    function setgaspricelimit(uint _gaspricelimit) external {
        require(msg.sender == gaslimitoracle, );
        require(_gaspricelimit > 0, );
        gaspricelimit = _gaspricelimit;
    }

    

    function exchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    )
        external
        
        onlysynthetixorsynth
        returns (uint)
    {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );
        require(exchangeenabled, );

        
        validategasprice(tx.gasprice);

        iexchangerates exrates = exchangerates();
        isynthetix _synthetix = synthetix();

        
        

        
        _synthetix.synths(sourcecurrencykey).burn(from, sourceamount);

        uint destinationamount = exrates.effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);

        (uint amountreceived, uint fee) = calculateexchangeamountminusfees(
            sourcecurrencykey,
            destinationcurrencykey,
            destinationamount
        );

        
        _synthetix.synths(destinationcurrencykey).issue(destinationaddress, amountreceived);

        
        if (fee > 0) {
            uint usdfeeamount = exrates.effectivevalue(destinationcurrencykey, fee, susd);
            _synthetix.synths(susd).issue(feepool().fee_address(), usdfeeamount);
            
            feepool().recordfeepaid(usdfeeamount);
        }

        

        
        _synthetix.emitsynthexchange(
            from,
            sourcecurrencykey,
            sourceamount,
            destinationcurrencykey,
            amountreceived,
            destinationaddress
        );

        return amountreceived;
    }

    

    

    modifier onlysynthetixorsynth() {
        require(
            msg.sender == address(synthetix()) || synthetix().getsynthbyaddress(msg.sender) != bytes32(0),
            
        );
        _;
    }
}
