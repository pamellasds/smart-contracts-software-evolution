pragma solidity 0.4.25;


import ;
import ;
import ;
import ;
import ;
import ;


contract isynthetix {
    

    ifeepool public feepool;
    isynthetixescrow public escrow;
    isynthetixescrow public rewardescrow;
    isynthetixstate public synthetixstate;
    iexchangerates public exchangerates;

    uint public totalsupply;

    mapping(bytes32 => synth) public synths;

    

    function balanceof(address account) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        public
        view
        returns (uint);

    function synthinitiatedexchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    ) external returns (bool);

    function exchange(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        external
        returns (bool);

    function collateralisationratio(address issuer) public view returns (uint);

    function totalissuedsynths(bytes32 currencykey) public view returns (uint);

    function getsynth(bytes32 currencykey) public view returns (isynth);

    function debtbalanceof(address issuer, bytes32 currencykey) public view returns (uint);
}
