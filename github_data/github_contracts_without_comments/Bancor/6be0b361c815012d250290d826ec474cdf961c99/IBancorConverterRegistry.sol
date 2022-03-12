pragma solidity 0.4.26;

contract ibancorconverterregistry {
    function tokens(uint256 _index) public view returns (address) { _index; }
    function tokencount() public view returns (uint256);
    function convertercount(address _token) public view returns (uint256);
    function converteraddress(address _token, uint32 _index) public view returns (address);
    function latestconverteraddress(address _token) public view returns (address);
    function tokenaddress(address _converter) public view returns (address);
}
