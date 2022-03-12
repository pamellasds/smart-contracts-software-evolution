pragma solidity 0.4.25;


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

    

    function balanceof(address account) public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    function effectivevalue(bytes4 sourcecurrencykey, uint sourceamount, bytes4 destinationcurrencykey) public view returns (uint);

    function synthinitiatedfeepayment(address from, bytes4 sourcecurrencykey, uint sourceamount) external returns (bool);
    function synthinitiatedexchange(
        address from,
        bytes4 sourcecurrencykey,
        uint sourceamount,
        bytes4 destinationcurrencykey,
        address destinationaddress) external returns (bool);
    function exchange(
        bytes4 sourcecurrencykey,
        uint sourceamount,
        bytes4 destinationcurrencykey,
        address destinationaddress) external returns (bool);
    function collateralisationratio(address issuer) public view returns (uint);
    function totalissuedsynths(bytes4 currencykey)
        public
        view
        returns (uint);
    function getsynth(bytes4 currencykey) public view returns (isynth);
    function debtbalanceof(address issuer, bytes4 currencykey) public view returns (uint);
}
