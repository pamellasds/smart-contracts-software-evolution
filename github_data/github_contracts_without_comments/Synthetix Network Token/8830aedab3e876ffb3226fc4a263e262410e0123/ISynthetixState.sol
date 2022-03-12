pragma solidity 0.4.25;

interface isynthetixstate {
    function getpreferredcurrency(address to) public view returns(bytes4);
    function debtledgerlength() external view returns (uint);
    function getdebtledgerat(uint index) public view returns (uint);
    function hasissued(address account) external view returns (bool);
    function incrementtotalissuercount() external;
    function decrementtotalissuercount() external;
    function setcurrentissuancedata(address account, uint initialdebtownership) external;
    function lastdebtledgerentry() external view returns (uint);
    function appenddebtledgervalue(uint value) external;
    function getissuancedata(address from) public view returns (uint, uint);
    function clearissuancedata(address account) external;
    function getissuanceratio() public view returns (uint);
}
