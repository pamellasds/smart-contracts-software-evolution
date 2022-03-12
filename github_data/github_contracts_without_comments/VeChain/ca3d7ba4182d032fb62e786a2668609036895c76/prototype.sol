pragma solidity ^0.4.23;















interface prototype {
    
    
    function master(address self) external view returns(address);

    
    
    
    function setmaster(address self, address newmaster) external;

    
    
    
    function balance(address self, uint blocknumber) external view returns(uint256);

    
    
    
    function energy(address self, uint blocknumber) external view returns(uint256);

    
    function hascode(address self) external view returns(bool);

    
    
    function storagefor(address self, bytes32 key) external view returns(bytes32);

    
    
    function creditplan(address self) external view returns(uint256 credit, uint256 recoveryrate);

    
    
    
    function setcreditplan(address self, uint256 credit, uint256 recoveryrate) external;

    
    function isuser(address self, address user) external view returns(bool);

    
    function usercredit(address self, address user) external view returns(uint256);

    
    function adduser(address self, address user) external;

    
    function removeuser(address self, address user) external;

    
    function sponsor(address self) external;

    
    function unsponsor(address self) external;

    
    function issponsor(address self, address sponsoraddress) external view returns(bool);

    
    function selectsponsor(address self, address sponsoraddress) external;  

    
    function currentsponsor(address self) external view returns(address);
}