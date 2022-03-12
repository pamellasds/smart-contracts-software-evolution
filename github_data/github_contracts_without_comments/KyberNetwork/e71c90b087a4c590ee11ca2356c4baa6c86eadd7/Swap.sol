pragma solidity 0.4.24;

import ;
import ;

contract swap {
    
    kybernetworkproxyinterface public kybernetworkcontract;
    
    event swapping(address indexed user, address indexed srctoken, address indexed desttoken); 
    
    function swap(
        erc20 src,
        uint srcamount,
        erc20 dest,
        address destaddress,
        uint maxdestamount,
        uint minconversionrate,
        address walletid
    ) public payable returns (uint256) {
        emit swapping(msg.sender, src, dest);
        return kybernetworkcontract.trade(
            src,
            srcamount,
            dest,
            destaddress,
            maxdestamount,
            minconversionrate,
            walletid
        );
    }
}
