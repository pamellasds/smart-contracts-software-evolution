pragma solidity >=0.4.24;


interface isystemstatus {
    struct status {
        bool cansuspend;
        bool canresume;
    }

    struct suspension {
        bool suspended;
        
        
        uint248 reason;
    }

    
    function accesscontrol(bytes32 section, address account) external view returns (bool cansuspend, bool canresume);

    function requiresystemactive() external view;

    function requireissuanceactive() external view;

    function requireexchangeactive() external view;

    function requiresynthactive(bytes32 currencykey) external view;

    function requiresynthsactive(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) external view;

    function synthsuspension(bytes32 currencykey) external view returns (bool suspended, uint248 reason);

    
    function suspendsynth(bytes32 currencykey, uint256 reason) external;

    function updateaccesscontrol(
        bytes32 section,
        address account,
        bool cansuspend,
        bool canresume
    ) external;
}
