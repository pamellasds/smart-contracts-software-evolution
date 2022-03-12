pragma solidity 0.4.24;

import ;


interface kybernetworkproxyinterface {
    function maxgasprice() public view returns(uint);
    function getusercapinwei(address user) public view returns(uint);
    function getusercapintokenwei(address user, erc20 token) public view returns(uint);
    function enabled() public view returns(bool);
    function info(bytes32 id) public view returns(uint);

    function getexpectedrate(erc20 src, erc20 dest, uint srcqty) public view
        returns (uint expectedrate, uint slippagerate);

    function tradewithhint(erc20 src, uint srcamount, erc20 dest, address destaddress, uint maxdestamount,
        uint minconversionrate, address walletid, bytes hint) public payable returns(uint);
    function trade(erc20 src, uint srcamount, erc20 dest, address destaddress, uint maxdestamount,
        uint minconversionrate, address walletid) public payable returns(uint);
}
